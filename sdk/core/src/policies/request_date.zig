const std = @import("std");
const Policy = @import("policy.zig").Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const RequestDatePolicy = @This();

xmsdate: []const u8 = undefined,

pub fn new(_xmsdate: []const u8) RequestDatePolicy {
    return RequestDatePolicy{
        .xmsdate = _xmsdate,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *RequestDatePolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-date", self.xmsdate);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *RequestDatePolicy) Policy {
    return Policy{
        .ptr = self,
        .sendFn = send,
    };
}
