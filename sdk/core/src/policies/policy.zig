const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Status = http.Status;


pub const Policy = struct {
    ptr: *anyopaque,
    value: []const u8,
    sendFn: *const fn (ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response,

    pub fn send(self: Policy, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
        return self.sendFn(self.ptr, arena, request, next);
    }
};
