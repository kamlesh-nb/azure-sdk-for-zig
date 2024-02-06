const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;
const Request = core.Request;
const Response = core.Response;

const QueryPolicy = @This();

query: []const u8 = undefined,

pub fn new(_query: []const u8) QueryPolicy {
    return QueryPolicy{
        .query = _query,
    };
}
 
pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *QueryPolicy = @ptrCast(@alignCast(ptr));
    request.parts.headers.add("x-ms-documentdb-isquery", self.query);
    return next[0].send(arena, request, next[1..]);
}

pub fn policy(self: *QueryPolicy) Policy {
    return Policy{
        .ptr = self,
        .sendFn = send,
    };
}
