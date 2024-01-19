const std = @import("std");
const ClientOptions = @import("options/client_options.zig");
const Policy = @import("policies/policy.zig").Policy;
const TelemetryPolicy = @import("policies/telemetry.zig");
const RetryPolicy = @import("policies/retry.zig");
const TransportPolicy = @import("policies/transport.zig");
// const Policies = @import("policies.zig");

const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const Policies = struct {
    items: []Policy = undefined,
    pos: usize = 0, // number of items in the list
    allocator: std.mem.Allocator = undefined,

    pub fn init(allocator: std.mem.Allocator, size: usize) !Policies {
        return Policies{
            .items = try allocator.alloc(Policy, size),
            .allocator = allocator,
        };
    }

    pub fn add(self: *Policies, policy: Policy) !void {
        if (self.pos == self.items.len) {
            self.items = try self.allocator.realloc(self.items, self.items.len * 2);
        }
        self.items[self.pos] = policy;
        self.pos += 1;
    }

    pub fn replace(self: *Policies, index: usize, policy: Policy) !void {
        self.items[index] = policy;
    }

    pub fn deinit(self: *Policies) void {
        self.allocator.free(self.items);
    }
};

const Pipeline = @This();

policies: Policies = undefined,
count: usize = 0,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Pipeline {
    return Pipeline{
        .allocator = allocator,
        .policies = try Policies.init(allocator, 6),
    };
}

pub fn addDefauls(self: *Pipeline, options: ClientOptions) !void {
    var rp = RetryPolicy.new(options.retry);
    var tp = TransportPolicy.new(options.transport);
    try self.policies.add(rp.policy());
    try self.policies.add(tp.policy());
}

pub fn send(self: *Pipeline, arena: *std.heap.ArenaAllocator, request: *Request) anyerror!Response {
    return try self.policies.items[0].send(arena, request, self.policies.items[1..self.policies.pos]);
}

pub fn deinit(self: *Pipeline) void {
    self.policies.deinit();
}
