const std = @import("std");
const core = @import("azcore");
const Policy = core.Policy;

const http = @import("http");
const Request = http.Request;
const Response = http.Response;
 

const DatePolicy = @This();


xmsdate: []const u8 = undefined,


pub fn new(_xmsdate: []const u8) DatePolicy {
    return DatePolicy{
        .xmsdate = _xmsdate,
    };
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request,  next: []const Policy.Policy) anyerror!Response {
        const self: *DatePolicy = @ptrCast(@alignCast(ptr));
        request.parts.headers.add("x-ms-date", self.xmsdate);
        return next[0].send(arena, request, next[1..]);
    }

    pub fn policy(self: *DatePolicy) Policy {
        return Policy{
            .ptr = self,
            .value = self.xmsdate,
            .sendFn = send,
        };
    }