const std = @import("std");
const time = std.time;
const Response = @import("http").Response;
const Policy = @import("policies.zig");
const HttpClient = @import("http_client.zig");
const CustomHttpClient = @import("custom_client.zig");

const policies = std.SinglyLinkedList(Policy.Policy);

pub const ClientOptions = struct {
    per_call_policies: policies,
    per_retry_policies: policies,
    retry: RetryOptions,
    telemetry: TelemetryOptions,
    transport: TransportOptions,

    pub fn new(appId: []const u8) ClientOptions {
        return ClientOptions{

            .per_call_policies = .{},
            .per_retry_policies = .{},

            .retry = RetryOptions{ .maxRetries = 3, .statusCodes = []u16{ 408, 429, 500, 502, 503, 504 }, .shouldRetry = true },

            .telemetry = TelemetryOptions{
                .applicationID = appId,
                .disabled = false,
            },

            .transport = TransportOptions{
                .timeout = 60_000,
                .httpClient = HttpClient{},
            },

        };
    }
};

pub const RetryOptions = struct {
    maxRetries: i32,
    statusCodes: []u16,
    shouldRetry: bool,
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

pub const TransportOptions = struct {
    timeout: u64,
    httpClient: HttpClient,
};
