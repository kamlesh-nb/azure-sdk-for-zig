const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;
 

const MaxItemPolicy = @This();


max_item: []const u8 = undefined,


pub fn new(_max_item: []const u8) MaxItemPolicy {
    return MaxItemPolicy{
        .max_item = _max_item,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request,  next: []const Policy.Policy) anyerror!Response {
        const self: *MaxItemPolicy = @ptrCast(@alignCast(ptr));
        request.parts.headers.add("x-ms-max-item-count", self.max_item);
        return next[0].send(arena, request, next[1..]);
    }

    pub fn policy(self: *MaxItemPolicy) Policy {
        return Policy{
            .ptr = self,
            .value = self.max_item,
            .sendFn = send,
        };
    }