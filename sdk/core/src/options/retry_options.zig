const std = @import("std");
const http = @import("http");
const Status = http.Status;

const RetryOptions = @This();

maxRetries: i32,
retryDelayInMs: u64 = 0,
maxRetryDelayInMs: u64 = 0,
statusCodes: [5]Status = [5]Status{ .too_many_requests, .internal_server_error, .bad_gateway, .service_unavailable, .gateway_timeout },
shouldRetry: bool,