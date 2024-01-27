const std = @import("std");

const SaleOrder = @import("sale_order.zig").SaleOrder;

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

    var container = try db.getContainer("SaleOrder");

    const saleOrder = .{
        .id = "174",
        .PoNumber = "PO123439186470",
        .OrderDate = "2005-09-12T00:00:00Z",
        .ShippedDate = "2005-07-28T00:00:00Z",
        .AccountNumber = "10-4332-000910",
        .RegionId = "SE",
        .SubTotal = 1219.4589,
        .TaxAmount = 122.5838,
        .Freight = 472.3108,
        .TotalDue = 985.018,
        .Items = .{
            .{ .OrderQty = 1, .ProductId = 1, .UnitPrice = 1219.4589, .LineTotal = 1219.4589 },
            .{ .OrderQty = 1, .ProductId = 2, .UnitPrice = 219.4589, .LineTotal = 219.4589 },
        },
    };

    const item = try container.createItem(SaleOrder, saleOrder, saleOrder.id);
    std.debug.print("Created Item:\n{any}", .{item});
}
