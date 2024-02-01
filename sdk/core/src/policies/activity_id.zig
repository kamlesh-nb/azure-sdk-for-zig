const std = @import("std");
const Policy = @import("policy.zig").Policy;
const uuid = @import("uuid.zig");

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const ActivityIdPolicy = @This();

pub fn new() ActivityIdPolicy {
    return ActivityIdPolicy{};
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *ActivityIdPolicy = @ptrCast(@alignCast(ptr));
    _ = self;
    var buf: [36:0]u8 = undefined;
    uuid.v4(&buf);
    request.parts.headers.add("x-ms-activity-id", buf[0..]);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *ActivityIdPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = undefined,
        .sendFn = send,
    };
}
