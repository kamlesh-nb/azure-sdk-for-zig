const std = @import("std");
const Buffer = @import("lib/http/buffer.zig");

const date = @import("lib/date/main.zig").datetime;
const tz = @import("lib/date/main.zig").timezones;
const Method = @import("lib/http//method.zig").Method;

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

pub const ResourceType = enum {
    dbs,
    colls,
    docs,
    sprocs,
    pkranges,
    pub fn toString(self: ResourceType) []const u8 {
        return switch (self) {
            .dbs => "dbs",
            .colls => "colls",
            .docs => "docs",
            .sprocs => "sprocs",
            .pkranges => "pkranges",
        };
    }
};

pub const DatabaseThoughputMode = enum {
    none,
    fixed,
    autopilot,
};

allocator: Allocator,
payload: Buffer,
authSig: Buffer,
auth: []const u8 = undefined,
timeStamp: []const u8 = undefined,

pub fn init(allocator: Allocator) !Authorization {
    return Authorization{
        .allocator = allocator,
        .payload = try Buffer.create(allocator, ""),
        .authSig = try Buffer.create(allocator, ""),
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

    var dbuf: [1024]u8 = undefined;
    const requestDate = std.ascii.lowerString(&dbuf, self.timeStamp);

    var mbuf:[8]u8 = undefined;
    const lowerMethod = std.ascii.lowerString(&mbuf,verb.toString());

    try self.payload.concat(lowerMethod);
    try self.payload.concat("\n");
    try self.payload.concat(resourceType.toString());
    try self.payload.concat("\n");
    try self.payload.concat(resourceLink);
    try self.payload.concat("\n");
    try self.payload.concat(requestDate);
    try self.payload.concat("\n");
    try self.payload.concat("\n");


    // std.debug.print("\nPayload: {s}\n", .{self.payload.str()});

    var kbuf: [64]u8 = undefined;
    try std.base64.standard.Decoder.decode(&kbuf, key);
    var hmacPayload: [cryptoHmac.mac_length]u8 = undefined;
    cryptoHmac.create(hmacPayload[0..], self.payload.str(), &kbuf);
    var buf: [128]u8 = undefined;
    const signature = std.base64.standard.Encoder.encode(&buf, &hmacPayload);
    try self.authSig.concat("type=");
    try self.authSig.concat(keyType);
    try self.authSig.concat("&");
    try self.authSig.concat("ver=");
    try self.authSig.concat(tokenVersion);
    try self.authSig.concat("&");
    try self.authSig.concat("sig=");
    try self.authSig.concat(signature);

    self.auth = try Uri.escapeString(self.allocator, self.authSig.str());
}

pub fn deinit(self: *Authorization) void {
    self.payload.deinit();
    self.authSig.deinit();
    self.allocator.free(self.auth);
    self.allocator.free(self.timeStamp);
}

test "tls" {}
