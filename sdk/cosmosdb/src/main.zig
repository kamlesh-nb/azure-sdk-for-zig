const std = @import("std");
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const http = @import("http");
const Method = http.Method;
const Request = http.Request;
const Response = http.Response;

const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");

pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const account = env.get("COSMOSDB_ACCOUNT").?;
    const key = env.get("COSMOSDB_KEY").?;
    var client = try CosmosClient.init(&Arena, account, key);
    const db = try client.getDatabase("floki");
    
    const parsed = try std.json.parseFromSlice(Database, Arena.allocator(), db, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
        
    });
    std.debug.print("parsed: {s}\n", .{parsed.value.id});
}
