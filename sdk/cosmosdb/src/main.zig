const std = @import("std");
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const http = @import("http");
const Method = http.Method;
const Request = http.Request;
const Response = http.Response;

const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");

const Item = struct {
    OrderQty: i32,
    ProductId: i32,
    UnitPrice: f64,
    LineTotal: f64,
};

pub const SaleOrder = struct {
    id: []const u8,
    PoNumber: []const u8,
    OrderDate: []const u8,
    ShippedDate: []const u8,
    AccountNumber: []const u8,
    RegionId: []const u8,
    SubTotal: f64,
    TaxAmount: f64,
    Freight: f64,
    TotalDue: f64,
    Items: []Item,
    _rid: []const u8 = undefined,
    _self: []const u8 = undefined,
    _etag: []const u8 = undefined,
    _ts: u64 = undefined,
    _attachments: []const u8 = undefined,
};

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
    // const cont = try db.createContainer(&client, "SaleOrder", "/id");

    var container = try db.getContainer(&client, "SaleOrder");

    const saleOrder = .{
        .id = "498",
        .PoNumber = "PO123439186470",
        .OrderDate = "2005-09-21T00:00:00Z",
        .ShippedDate = "2005-07-28T00:00:00Z",
        .AccountNumber = "10-4332-000910",
        .RegionId = "RU",
        .SubTotal = 1219.4589,
        .TaxAmount = 122.5838,
        .Freight = 472.3108,
        .TotalDue = 985.018,
        .Items = .{
            .{ .OrderQty = 1, .ProductId = 1, .UnitPrice = 1219.4589, .LineTotal = 1219.4589 },
            .{ .OrderQty = 1, .ProductId = 2, .UnitPrice = 219.4589, .LineTotal = 219.4589 },
        },
    };

    const item = try container.createItem(&client, db.id, SaleOrder, saleOrder, saleOrder.id);
    std.debug.print("\nParsed: {any}\n", .{item});
}
