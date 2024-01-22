// x-ms-documentdb-partitionkey

const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const PartitionKeyPolicy = @This();

partition_key: []const u8 = undefined,

pub fn new(_partition_key: []const u8) PartitionKeyPolicy {
    return PartitionKeyPolicy{
        .partition_key = _partition_key,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *PartitionKeyPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-documentdb-partitionkey", self.partition_key);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *PartitionKeyPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.partition_key,
        .sendFn = send,
    };
}
