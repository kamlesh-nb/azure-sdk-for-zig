const std = @import("std");
const Client = @import("fetch").Client;
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Method = http.Method;
const Version = http.Version;
const TelemetryPolicy = @import("policies/telemetry.zig");
const RetryPolicy = @import("policies/retry.zig");
const TransportPolicy = @import("policies/transport.zig");

const ClientOptions = @import("options/client_options.zig");
const Policy = @import("policies/policy.zig").Policy;
const Pipeline = @import("pipeline.zig");



pub const TryPolicy = struct {
    value: []const u8,

    pub fn new(value: []const u8) TryPolicy {
        return TryPolicy{ .value = value };
    }

    pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
        const self: *TryPolicy = @ptrCast(@alignCast(ptr));
        request.parts.headers.add("user-agent-try", self.value);
        return next[0].send(arena, request, next[1..]);
    }

    pub fn policy(self: *TryPolicy) Policy {
        return Policy{
            .ptr = self,
            .value = self.value,
            .sendFn = send,
        };
    }
};



pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();

    const options = try ClientOptions.new(allocator, "azure.core.zig.v0.0.1");
 
    var tr = TryPolicy.new("try");

    var pipeline = try Pipeline.init(allocator);
    defer pipeline.deinit();

    try pipeline.policies.add(tr.policy());
    var tep = TelemetryPolicy.new("azure.core.zig.v0.0.1");
    try pipeline.policies.add(tep.policy());
    try pipeline.addDefauls(options);

    const uri = std.Uri{
        .scheme = "https",
        .host = "jsonplaceholder.typicode.com",
        .port = 443,
        .fragment = null,
        .path = "/todos",
        .password = null,
        .query = null,
        .user = null,
    };
    var request = try Request.new(allocator, uri, .get, .Http11);
    defer request.deinit();

    request.parts.headers.add("Accept", "application/json");
    request.parts.headers.add("Host", "jsonplaceholder.typicode.com");
    request.parts.headers.add("Accept-Language", "en-US,en;q=0.9,nl;q=0.8");
    request.parts.headers.add("Upgrade-Insecure-Requests", "1");

    var response = try pipeline.send(
        &Arena,
        &request,
    );
    defer response.deinit();
    std.debug.print("{s}\n", .{response.body.buffer.str()});
}
