const std = @import("std");
const Client = @import("fetch").Client;
const httpz = @import("http");
const Request = httpz.Request;
const Response = httpz.Response;

const HttpClient = @This();

pub fn executeRequest(self: *HttpClient, allocator: std.mem.Allocator, request: Request) !Response {
    _ = self;
    var client = Client{
        .allocator = allocator,
        .hostname = request.parts.uri.host.?,
        .port = request.parts.uri.port.?,
        .protocol = if (std.mem.eql(u8, request.parts.uri.scheme, "https")) .tls else .plain,
    };
    
    defer client.deinit();
    try client.connect();

    var sender = request.sender();
    const len = try sender.send(client.writer());
    std.debug.print("Bytes written: {d} \n", .{len});

    var res = try Response.init(allocator);
    defer res.deinit();

    var parser = res.parser();
    try parser.parse(client.reader());

    return res;

}
