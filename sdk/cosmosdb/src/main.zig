const std = @import("std");
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const http = @import("http");
const Method = http.Method;
const Request = http.Request;
const Response = http.Response;
const Query = @import("resources/query.zig").Query;
const Parameter = @import("resources/query.zig").Parameter;

const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");
const Container = @import("container.zig");

const Item = struct {
    OrderQty: i32,
    ProductId: i32,
    UnitPrice: f64,
    LineTotal: f64,
};

pub const SaleOrder = struct {
    id: []const u8 = undefined,
    PoNumber: []const u8 = undefined,
    OrderDate: []const u8 = undefined,
    ShippedDate: []const u8 = undefined,
    AccountNumber: []const u8 = undefined,
    RegionId: []const u8 = undefined,
    SubTotal: f64 = undefined,
    TaxAmount: f64 = undefined,
    Freight: f64 = undefined,
    TotalDue: f64 = undefined,
    Items: []Item = undefined,
    _rid: []const u8 = undefined,
    _self: []const u8 = undefined,
    _etag: []const u8 = undefined,
    _ts: u64 = undefined,
    _attachments: []const u8 = undefined,
};

const SaleOrders = struct {
    _rid: []const u8,
    Documents: []SaleOrder,
    _count: u64,
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
    // const db = try client.createDatabase("floki");

    var db = try client.getDatabase("floki");

    if (db.errors) |err|  {
        std.debug.print("\nDatabase: {s}\n", .{err.errorCode});
        return;
    }

    // _ = try db.createContainer("SaleOrder", "/id");
    // std.debug.print("\nParsed: {any}\n", .{db.db.id});
    // try db.deleteContainer("SaleOrder");
    // const cont = try db.createContainer("SaleOrder", "/id");

    var con = try db.value.?.getContainer("SaleOrder");

    if (con.errors) |err| {
        std.debug.print("\nContainer Error: {s}\n", .{err.errorCode});
        return;
    }
    const so = try con.value.?.readItem(SaleOrder, "1148", "148");
    if (so.value) |v| {
        std.debug.print("\nItem Read: {any}\n", .{v});
    } else {
        std.debug.print("\nItem Error: {s}\n", .{so.errors.?.rawResponse});
    }

    const saleOrder = .{
        .id = "468",
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
    _ = saleOrder;

    // const item = try container.createItem(SaleOrder, saleOrder, saleOrder.id);
    // if (item.value) | doc |{
    //     std.debug.print("\nItem Created: {any}\n", .{doc});
    // } else {
    //     std.debug.print("\nError: {s}\n", .{item.errors.?.errorCode});
    // }
    // const items = try container.readItems(SaleOrders);
    // std.debug.print("\nAll Items: {any}\n", .{items});
    // const qry = .{
    //     .query = "SELECT * FROM SaleOrder s WHERE s.RegionId = @regionId",
    //     .parameters = .{
    //         .{ .name = "@regionId", .value = "WA" },
    //     },
    // };

    // const result = try container.queryItems(SaleOrders, qry);
    // std.debug.print("\nQuery Results: \n{any}\n", .{result});

    // var doc = result.Documents[0];
    // doc.ShippedDate = "2005-12-21T00:00:00Z";
    // doc.RegionId = "RU";
    // const upd = try container.updateItem(SaleOrder, doc, doc.id, doc.id);
    // std.debug.print("\nParsed: {any}\n", .{upd});

    // const result = try container.deleteItem("368", "368");

    // if (result.errors) |err| {
    //     std.debug.print("\nError: {s}\n", .{err.errorCode});
    // }

}
