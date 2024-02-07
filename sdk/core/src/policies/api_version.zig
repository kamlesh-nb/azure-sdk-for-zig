const std = @import("std");
const Policy = @import("policy.zig").Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const ApiVersionPolicy = @This();

api_version: []const u8 = undefined,

pub fn new(apiversion: []const u8) ApiVersionPolicy {
    return ApiVersionPolicy{
        .api_version = apiversion,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *ApiVersionPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-version", self.api_version);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *ApiVersionPolicy) Policy {
    return Policy{
        .ptr = self,
        .sendFn = send,
    };
}
