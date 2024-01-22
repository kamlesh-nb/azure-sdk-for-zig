const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const ThroughputPolicy = @This();

throughput: []const u8 = undefined,

pub fn new(_throughput: []const u8) ThroughputPolicy {
    return ThroughputPolicy{
        .throughput = _throughput,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *ThroughputPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-offer-throughput", self.throughput);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *ThroughputPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.throughput,
        .sendFn = send,
    };
}
