// x-ms-documentdb-partitionkey

const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

 
const Request = core.Request;
const Response = core.Response;

const PartitionKeyPolicy = @This();

partition_key: []const u8 = undefined,

pub fn new(_partition_key: []const u8) PartitionKeyPolicy {
    return PartitionKeyPolicy{
        .partition_key = _partition_key,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *PartitionKeyPolicy = @ptrCast(@alignCast(ptr));
    var pk:[256]u8 = undefined;
    const strPk = try std.fmt.bufPrint(&pk, "[\"{s}\"]", .{self.partition_key});
    // std.debug.print("\nPartitionKeyPolicy: {s}\n", .{strPk[0..strPk.len]});
    request.parts.headers.add("x-ms-documentdb-partitionkey", strPk[0..strPk.len]);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *PartitionKeyPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.partition_key,
        .sendFn = send,
    };
}
