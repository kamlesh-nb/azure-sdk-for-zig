const std = @import("std");
const Policy = @import("policy.zig").Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const ClientRequestIdPolicy = @This();


pub fn new() ClientRequestIdPolicy {
    return ClientRequestIdPolicy{};
}


pub fn randId32(self: *ClientRequestIdPolicy, buf: []u8) ![] u8 {
    _ = self;
    const chars:[62]u8 = [_]u8{ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
    const RndGen = std.rand.DefaultPrng;
    var seed: u64 = undefined;
    std.os.getrandom(std.mem.asBytes(&seed)) catch unreachable;
    var rnd = RndGen.init(seed);

    const max: u8 = 32;
    var i: u8 = 0;
    var rand_id: [32]u8 = undefined;
    while (i < max) {
        const _rand_id = rnd.random().intRangeLessThan(usize, 0, chars.len);
        rand_id[i] = chars[_rand_id];
        i += 1;
    }
  
    return try std.fmt.bufPrint(buf, "{s}-{s}-{s}-{s}-{s}", .{rand_id[0..8], rand_id[8..12], rand_id[12..16], rand_id[16..20], rand_id[20..32]});

}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *ClientRequestIdPolicy = @ptrCast(@alignCast(ptr));
      var buf: [36]u8 = undefined;
      _ = try self.randId32(&buf);
    request.parts.headers.add("x-ms-client-request-id", buf[0..]);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *ClientRequestIdPolicy) Policy {
    return Policy{
        .ptr = self,
        .value =undefined,
        .sendFn = send,
    };
}
