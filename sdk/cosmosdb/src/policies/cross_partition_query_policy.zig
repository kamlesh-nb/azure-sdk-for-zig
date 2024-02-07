const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;
const Request = core.Request;
const Response = core.Response;

const CrossPartitionQueryPolicy = @This();

cross_partition_query: []const u8 = undefined,

pub fn new(_cross_partition_query: []const u8) CrossPartitionQueryPolicy {
    return CrossPartitionQueryPolicy{
        .cross_partition_query = _cross_partition_query,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *CrossPartitionQueryPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-documentdb-query-enablecrosspartition", self.cross_partition_query);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *CrossPartitionQueryPolicy) Policy {
    return Policy{
        .ptr = self,
        .sendFn = send,
    };
}
