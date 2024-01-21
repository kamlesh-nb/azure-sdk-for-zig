const std = @import("std");
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const http = @import("http");
const Method = http.Method;
const Request = http.Request;
const Response = http.Response;

const CosmosClient = @import("cosmos.zig");

pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();
    _ = allocator;
    var client = try CosmosClient.init(&Arena, "flokidb", "");
    const db = client.getDatabase("floki");
    _ = db;
}
