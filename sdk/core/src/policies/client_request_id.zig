const std = @import("std");
const Policy = @import("policy.zig").Policy;
const uuid = @import("uuid.zig");

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const ClientRequestIdPolicy = @This();

pub fn new() ClientRequestIdPolicy {
    return ClientRequestIdPolicy{};
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *ClientRequestIdPolicy = @ptrCast(@alignCast(ptr));
    _ = self;
    var buf: [36:0]u8 = undefined;
    uuid.v4(&buf);
    request.parts.headers.add("x-ms-client-request-id", buf[0..]);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *ClientRequestIdPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = undefined,
        .sendFn = send,
    };
}
