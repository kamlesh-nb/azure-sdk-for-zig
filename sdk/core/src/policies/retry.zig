const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Status = http.Status;

const RetryOptions = @import("../options/retry_options.zig");
const Policy = @import("policy.zig").Policy;

const RetryPolicy = @This();

options: RetryOptions,
retryDelayInMs: u64 = 1000,
maxRetryDelayInMs: u64 = 1000 * 64,
value: []const u8 = undefined,

fn wait(self: *RetryPolicy, duration: u64) void {
    _ = self;
    std.time.sleep(duration);
}

fn calculateExponentialDelay(self: *RetryPolicy, retries: u32) u64 {
    const exponentialDelay = self.retryDelayInMs * std.math.pow(u64, 2, retries);
    return @min(self.maxRetryDelayInMs, exponentialDelay);
}

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *RetryPolicy = @ptrCast(@alignCast(ptr));
    var retries: u32 = 0;
    var delay: u64 = 0;
    while (true) {
        const response = try next[0].send(arena, request, next[1..]);

        switch (response.parts.status) {
            .ok, .created, .no_content => {
                return response;
            },
            .too_many_requests => {

                //expecting any of the below headers will be sent by the server
                const retry_after = response.parts.headers.get("Retry-After");
                const retry_after_ms = response.parts.headers.get("retry-after-ms");
                const x_ms_retry_after_ms = response.parts.headers.get("x-ms-retry-after-ms");

                if (retry_after) |ra| {
                    const _retry_after: u64 = try std.fmt.parseInt(u64, ra, 10);
                    delay = _retry_after * 1000000000;
                    self.wait(delay);
                } else if (retry_after_ms) |ram| {
                    const _retry_after_ms: u64 = try std.fmt.parseInt(u64, ram, 10);
                    delay = _retry_after_ms * 1000000;
                    self.wait(delay);
                } else if (x_ms_retry_after_ms) |xram| {
                    const _x_ms_retry_after_ms: u64 = try std.fmt.parseInt(u64, xram, 10);
                    delay = _x_ms_retry_after_ms * 1000000;
                    self.wait(delay);
                }
            },
            .internal_server_error, .bad_gateway, .service_unavailable, .gateway_timeout, .request_timeout => {
                if (retries > self.options.maxRetries) {
                    return response;
                }
                const exponentialDelay = self.calculateExponentialDelay(retries);
                self.wait(exponentialDelay);
                retries += 1;
            },
            else => {
                return response;
            },
        }
    }
}

pub fn new(opt: RetryOptions) RetryPolicy {
    return RetryPolicy{
        .options = opt,
    };
}

pub fn policy(self: *RetryPolicy) Policy {
    return Policy{
        .ptr = self,
        .value = self.value,
        .sendFn = send,
    };
}
