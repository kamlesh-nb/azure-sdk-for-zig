const std = @import("std");
const time = std.time;
const http = @import("http");
const Response = http.Response;
const Status = http.Status;
const Policy = @import("../policies/policy.zig").Policy;
const RetryOptions = @import("retry_options.zig");
const TelemetryOptions = @import("telemetry_options.zig");
const TransportOptions = @import("transport_options.zig");
const HttpClient = @import("../http_client.zig");


const ClientOptions = @This();

per_call_policies: []const Policy = undefined,
per_retry_policies: []const Policy = undefined,
retry: RetryOptions,
telemetry: TelemetryOptions,
transport: TransportOptions,
allocator: std.mem.Allocator,
pub fn new(allocator: std.mem.Allocator, appId: []const u8) !ClientOptions {
    return ClientOptions{
        .allocator = allocator,

        .retry = RetryOptions{ .maxRetries = 3, .shouldRetry = true },

        .telemetry = TelemetryOptions{
            .applicationID = try allocator.dupe(u8, appId),
            .disabled = false,
        },

        .transport = TransportOptions{
            .timeout = 60,
            .httpClient = HttpClient{ .allocator = allocator },
        },
    };
}
