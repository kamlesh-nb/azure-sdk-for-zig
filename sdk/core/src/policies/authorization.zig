const std = @import("std");
const Policy = @import("policy.zig").Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const AuthorizationPolicy = @This();

authsig: []const u8 = undefined,

pub fn new(signature: []const u8) AuthorizationPolicy {
    return AuthorizationPolicy{
        .authsig = signature,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *AuthorizationPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("Authorization", self.authsig);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *AuthorizationPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.authsig,
        .sendFn = send,
    };
}
