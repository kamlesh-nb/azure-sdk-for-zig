const std = @import("std");
const time = std.time;
const Response = @import("http").Response;
const Policy = @import("policies.zig");

pub const ClientOptions = struct {
    /// Policies called per call.
    per_call_policies: []Policy.Policy,
    /// Policies called per retry.
    per_retry_policies: []Policy.Policy,
    /// Retry options.
    retry: RetryOptions,
    /// Telemetry options.
    telemetry: TelemetryOptions,
    /// Transport options.
    transport: TransportOptions,
    /// Transport options.
    timeout: Policy.TimeoutPolicy,
};



pub const RetryOptions = struct {
    maxRetries: i32,
    tryTimeout: time.epoch,
    retryDelay: time.epoch,
    maxRetryDelay: time.Duration,
    statusCodes: []u16,
    shouldRetry: fn (*Response, anytype) bool,
};

pub const TelemetryOptions = struct {
    applicationID: []const u8,
    disabled: bool,
};

pub const TokenRequestOptions = struct {
    claims: []const u8,
    enableCAE: bool,
    scopes: []const u8,
    tenantID: []const u8,
};

const TransportOptions = union(enum) {
    HttpClient,
    CustomHttpClient,
};
