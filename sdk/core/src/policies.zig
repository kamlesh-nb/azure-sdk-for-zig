const std = @import("std");

const Policy = struct {
    ptr: *anyopaque,
    sendFn: *const fn (ptr: *anyopaque, data: []const u8) anyerror!void,

    fn send(self: Policy, data: []const u8) !void {
        return self.sendFn(self.ptr, data);
    }
};


pub const TimeoutPolicy = struct {
    timeout: std.time.Timer,
};