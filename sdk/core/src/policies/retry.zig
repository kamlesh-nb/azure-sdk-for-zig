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

pub fn send(ptr: *anyopaque, arena: *std.heap.ArenaAllocator, request: *Request, next: []const Policy) anyerror!Response {
    const self: *RetryPolicy = @ptrCast(@alignCast(ptr));
    var retries: u32 = 0;
    while (true) {
        const response = try next[0].send(arena, request, next[1..]);
        if (response.parts.status != Status.ok) {
            if (retries > self.options.maxRetries) {
                return response;
            }
            if (response.parts.status == Status.bad_request) {
                return response;
            } else if (response.parts.status == Status.too_many_requests) {
                // const retry_after =  response.parts.headers.get("Retry-After"); / /TODO: parse this
                const retry_after_ms = response.parts.headers.get("retry-after-ms");
                const x_ms_retry_after_ms = response.parts.headers.get("x-ms-retry-after-ms");
                if (retry_after_ms) |ra| {
                    const _retry_after_ms: u64 = try std.fmt.parseInt(u64, ra, 10);
                    self.wait(_retry_after_ms);
                } else if (x_ms_retry_after_ms) |xra| {
                    const _x_ms_retry_after_ms: u64 = try std.fmt.parseInt(u64, xra, 10);
                    self.wait(_x_ms_retry_after_ms);
                }
            } else {
                const exponentialDelay = self.options.retryDelayInMs * std.math.pow(u64, 2, retries);
                const clampedExponentialDelay = @min(self.options.maxRetryDelayInMs, exponentialDelay);
                self.wait(clampedExponentialDelay);
            }
            retries += 1;
        } else {
            return response;
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
