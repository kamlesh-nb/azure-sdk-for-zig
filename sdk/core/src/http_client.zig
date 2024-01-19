const std = @import("std");
const Client = @import("fetch").Client;
const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const HttpClient = @This();

allocator: std.mem.Allocator,

pub fn executeRequest(self: *HttpClient, arena: *std.heap.ArenaAllocator, request: *Request) !Response {
    _ = self;

    const alloca = arena.allocator();

    var client = Client{
        .allocator = alloca,
        .hostname = request.parts.uri.host.?,
        .port = request.parts.uri.port.?,
        .protocol = if (std.mem.eql(u8, request.parts.uri.scheme, "https")) .tls else .plain,
    };
    defer client.deinit();
    try client.connect();

    var sender = request.sender();
   _  = try sender.send(client.writer());

    var response = try Response.init(alloca);
    var parser = response.parser();
    try parser.parse(client.reader());
    return response;
}
