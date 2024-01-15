const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const options = @import("options.zig");

const Policy = struct {
    ptr: *anyopaque,
    sendFn: *const fn (ptr: *anyopaque, request: *Request) anyerror!void,

    fn send(self: Policy, request: *Request) anyerror!void {
        return self.sendFn(self.ptr, request);
    }

};

pub const RetryPolicy = struct {
    options: options.RetryOptions,

    pub fn send(ptr: *anyopaque, request: *Request) anyerror!void {
        _ = request;
        _ = ptr;

        while (true) {

        }
        
    }

    pub fn policy(self: *RetryPolicy) Policy {
        return Policy{
            .ptr = self,
            .sendFn = send,
        };
    }

};


pub const TelemetryPolicy = struct {
    name: []const  u8,
    value: []const  u8,

    pub fn new(name: []const u8, value: []const u8) TelemetryPolicy {
        return TelemetryPolicy{ .name = name, .value = value };
    }

    pub fn send(ptr: *anyopaque, request: *Request) anyerror!void {
        request.headers.add(ptr.name, ptr.value);
    }

    pub fn policy(self: *TelemetryPolicy) Policy {
        return Policy{
            .ptr = self,
            .sendFn = send,
        };
    }

};

pub const TransportPolicy = struct {
    transport: options.TransportOptions.httpClient,
    
    pub fn send(ptr: *anyopaque, request: *Request) anyerror!void {
        ptr.transport.executeRequest(request);
    }

    pub fn policy(self: *TransportPolicy) Policy {
        return Policy{
            .ptr = self,
            .sendFn = send,
        };
    }
 
};