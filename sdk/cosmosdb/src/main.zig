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


    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();
     

    var iter = env.iterator();

    while (iter.next()) |entry| {
        std.debug.print("{s}={s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("{s}={any}\n", .{ "Account: ", env.get("COSMOSDB_ACCOUNT") });
    std.debug.print("{s}={any}\n", .{ "Key: ", env.get("COSMOSDB_KEY") });
    
    const account = env.get("COSMOSDB_ACCOUNT").?;
    const key = env.get("COSMOSDB_KEY").?;
    var client = try CosmosClient.init(&Arena, account, key);
    const db = try client.getDatabase("floki");
    _ = db;
    
}
