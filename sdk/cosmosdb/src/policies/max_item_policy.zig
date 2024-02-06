const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

const Request = core.Request;
const Response = core.Response;

const MaxItemPolicy = @This();

max_item: u64 = 0,

pub fn new(_max_item: u64) MaxItemPolicy {
    return MaxItemPolicy{
        .max_item = _max_item,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *MaxItemPolicy = @ptrCast(@alignCast(ptr));
    var buf: [10]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{self.max_item});
    request.parts.headers.add("x-ms-max-item-count", str[0..str.len]);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *MaxItemPolicy) Policy {
    return Policy{
        .ptr = self,
        .sendFn = send,
    };
}
