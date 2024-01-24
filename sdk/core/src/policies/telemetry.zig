const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Status = http.Status;

const Policy = @import("policy.zig").Policy;

const TelemetryPolicy = @This();

value: []const u8,

pub fn new(appId: []const u8) TelemetryPolicy {
    return TelemetryPolicy{
        .value = appId,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *TelemetryPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("User-Agent", self.value);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *TelemetryPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.value,
        .sendFn = send,
    };
}
