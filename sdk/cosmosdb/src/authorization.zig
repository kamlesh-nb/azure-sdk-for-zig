const std = @import("std");
const Buffer = @import("buffer");
const Enums = @import("enums.zig");
const date = @import("datetime").datetime;
const tz = @import("datetime").timezones;
const http = @import("http");
const Method = http.Method;

const ResourceType = Enums.ResourceType;
const DatabaseThoughputMode = Enums.DatabaseThoughputMode;

const crypto = std.crypto;
const cryptoHmac = std.crypto.auth.hmac.sha2.HmacSha256;
const base64Decoder = std.base64.Base64Decoder;
const base64Encoder = std.base64.Base64Encoder;
const testing = std.testing;
const mem = std.mem;
const net = std.net;
const Uri = std.Uri;
const Allocator = mem.Allocator;

const Authorization = @This();

allocator: Allocator,
payload: Buffer,
authSig: Buffer,
auth: Buffer,
timeStamp: []const u8 = undefined,

pub fn init(allocator: Allocator) !Authorization {
    return Authorization{
        .allocator = allocator,
        .payload = try Buffer.init(allocator),
        .authSig = try Buffer.init(allocator),
        .auth = try Buffer.init(allocator),
    };
}

pub fn getTimeStamp(self: *Authorization) !void {
    const dt = date.Datetime.now();
    const gmtDateTime = try date.Datetime.create(dt.date.year, dt.date.month, dt.date.day, dt.time.hour, dt.time.minute, dt.time.second, dt.time.nanosecond, &tz.GMT);
    self.timeStamp = try gmtDateTime.formatHttp(self.allocator);
}

pub fn genAuthSig(self: *Authorization, verb: Method, resourceType: ResourceType, resourceLink: []const u8, key: []const u8) !void {
    const keyType = "master";
    const tokenVersion = "1.0";
    try self.getTimeStamp();
    var dbuf: [128]u8 = undefined;
    const requestDate = std.ascii.lowerString(&dbuf, self.timeStamp);

    var mbuf: [8]u8 = undefined;
    const lowerMethod = std.ascii.lowerString(&mbuf, verb.toString());

    _ = try self.payload.write("{s}\n{s}\n{s}\n{s}\n\n", .{ lowerMethod, resourceType.toString(), resourceLink, requestDate });

    var kbuf: [64]u8 = undefined;
    try std.base64.standard.Decoder.decode(&kbuf, key);
    var hmacPayload: [cryptoHmac.mac_length]u8 = undefined;
    cryptoHmac.create(hmacPayload[0..], try self.payload.getWritten(), &kbuf);
    var buf: [128]u8 = undefined;
    const signature = std.base64.standard.Encoder.encode(&buf, &hmacPayload);

    _ = try self.authSig.write("type={s}&ver={s}&sig={s}", .{ keyType, tokenVersion, signature });
    // std.debug.print("{s}\n", .{try self.authSig.getWritten()});

    const authEscaped = try Uri.escapeString(self.allocator, try self.authSig.getWritten());
    // std.debug.print("{s}\n", .{authEscaped});
    _ = try self.auth.write("{s}", .{authEscaped});

    self.allocator.free(authEscaped);
}

pub fn deinit(self: *Authorization) void {
    self.payload.deinit();
    self.authSig.deinit();
    self.auth.deinit();
    self.allocator.free(self.timeStamp);
}
