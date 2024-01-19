const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Status = http.Status;

const TransportOptions = @import("../options/transport_options.zig");
const Policy = @import("policy.zig").Policy;

const TransportPolicy = @This();

transport: TransportOptions,
value: []const u8 = undefined,

pub fn new(opt: TransportOptions) TransportPolicy {
    return TransportPolicy{
        .transport = opt,
    };
}
pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    _ = next;

    const self: *TransportPolicy = @ptrCast(@alignCast(ptr));
    return try self.transport.httpClient.executeRequest(arena, request);
}

pub fn policy(self: *TransportPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.value,
        .sendFn = send,
    };
}
