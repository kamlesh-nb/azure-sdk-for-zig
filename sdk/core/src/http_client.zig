const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const tls = @import("tls");

const Connect = @import("connect.zig");
const Stream = @import("stream.zig").Stream;
const aio = @import("aio");
const coro = @import("coro");

const HttpClient = @This();

pub fn executeRequest(self: *HttpClient, arena: *std.heap.ArenaAllocator, request: *Request) !Response {
    _ = self;

    const allocator = arena.allocator();

    // var client = Client{
    //     .allocator = allocator,
    //     .hostname = request.parts.uri.host.?,
    //     .port = request.parts.uri.port.?,
    //     .protocol = if (std.mem.eql(u8, request.parts.uri.scheme, "https")) .tls else .plain,
    // };

    // defer client.deinit();
    // try client.connect();

    // var sender = request.sender();
    // _ = try sender.send(client.writer());

    // var response = try Response.init(allocator);
    // var parser = response.parser();
    // try parser.parse(client.reader());
    // try client.close();
    return response;
}
