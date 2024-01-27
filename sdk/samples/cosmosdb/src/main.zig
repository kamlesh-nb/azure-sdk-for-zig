const std = @import("std");

const cosmos = @import("azcosmos");

const CosmosClient = cosmos.CosmosClient;
const Database = cosmos.Database;

pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const account = env.get("COSMOSDB_ACCOUNT").?;
    const key = env.get("COSMOSDB_KEY").?;
    var client = try CosmosClient.init(&Arena, account, key);


    var db = try client.getDatabase("floki");

    const container = try db.getContainer("SaleOrder");
    _ = container;
}
