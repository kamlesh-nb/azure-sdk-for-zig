const std = @import("std");
const Authorization = @import("authorization.zig");
 
const core = @import("azcore");
const IsoDate = core.IsoDate;
const Uuid = core.Uuid;

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
    _rid: []const u8 = undefined,
    Documents: []SaleOrder = undefined,
    _count: u64 = undefined,
};

pub fn main() !void {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();

    var env = try std.process.getEnvMap(allocator);

    const account = env.get("COSMOSDB_ACCOUNT").?;
    const key = env.get("COSMOSDB_KEY").?;
    var client = try CosmosClient.init(&Arena, account, key);

    const db = try client.getDatabase("floki");

    var flokiDb = switch (db) {
        .Ok => db.Ok,
        .Error => {
            std.debug.print("\nDatabase: {s}\n", .{db.Error.rawResponse});
            return;
        },
    };

    const con = try flokiDb.getContainer("SaleOrder");

    var containerSO = switch (con) {
        .Ok => con.Ok,
        .Error => {
            std.debug.print("\nContainer: {s}\n", .{con.Error.errorCode});
            return;
        },
    };

    const so = try containerSO.readItem(SaleOrder, "629e34962898482f", "629e34962898482f");

    const soItem = switch (so) {
        .Ok => so.Ok,
        .Error => {
            std.debug.print("\nItem Error: {s}\n", .{so.Error.errorCode});
            return;
        },
    };

    std.debug.print("\nItem Read: {any}\n", .{soItem});

    var d: [33]u8 = undefined;
    var t: [33]u8 = undefined;
    var date = IsoDate.now();
    var shipDate = IsoDate.addDays(12);
    var id: [16:0]u8 = undefined;
    var po: [16:0]u8 = undefined;
    var ac: [16:0]u8 = undefined;
    Uuid.docId(&id);
    Uuid.docId(&po);
    Uuid.docId(&ac);

    var saleOrder = .{
        .id = id,
        .PoNumber = po,
        .OrderDate = try date.isoDate(&d),
        .ShippedDate = try shipDate.isoDate(&t),
        .AccountNumber = ac,
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

    const item = try containerSO.createItem(SaleOrder, saleOrder, &saleOrder.id);

    const createdItem = switch (item) {
        .Ok => item.Ok,
        .Error => {
            std.debug.print("\nItem Error: {s}\n", .{item.Error.errorCode});
            return;
        },
    };
    
    std.debug.print("\nItem Created: id = {s}\n", .{createdItem.id});

    const qry = .{
        .query = "SELECT * FROM SaleOrder s WHERE s.RegionId = @regionId",
        .parameters = .{
            .{ .name = "@regionId", .value = "SE" },
        },
    };

    const result = try containerSO.queryItems(SaleOrders, qry);

    const queryResult = switch (result) {
        .Ok => result.Ok,
        .Error => {
            std.debug.print("\nQuery Error: {s}\n", .{result.Error.errorCode});
            return;
        },
    };

    std.debug.print("\nQuery Results: \n{any}\n", .{queryResult});

    if (queryResult._count > 0) {
        var doc = queryResult.Documents[0];
        var shipDateUpdate = IsoDate.addDays(12);

        doc.ShippedDate = try shipDateUpdate.isoDate(&t);
        doc.RegionId = "EU";
        const upd = try containerSO.updateItem(SaleOrder, doc, doc.id, doc.id);

        const updatedItem = switch (upd) {
            .Ok => upd.Ok,
            .Error => {
                std.debug.print("\nUpdate Error: {s}\n", .{upd.Error.errorCode});
                return;
            },
        };

        std.debug.print("\nParsed: {any}\n", .{updatedItem});
    }

    const patch = .{
        .condition = "from c where c.RegionId = 'EU' ",
        .operations = .{
            .{ .op = "replace", .path = "/RegionId", .value = "EU" },
            .{ .op = "add", .path = "/Items", .value = .{
                .{ .OrderQty = 1, .ProductId = 1, .UnitPrice = 1219.4589, .LineTotal = 1219.4589 },
                .{ .OrderQty = 1, .ProductId = 2, .UnitPrice = 219.4589, .LineTotal = 219.4589 },
                .{ .OrderQty = 1, .ProductId = 3, .UnitPrice = 319.4589, .LineTotal = 319.4589 },
            },}
        },
    };

    const patchResult = try containerSO.patchItem(SaleOrder, "202", "202", patch);

    const patchedItem = switch (patchResult) {
        .Ok => patchResult.Ok,
        .Error => {
            std.debug.print("\nPatch Error: {s}\n", .{patchResult.Error.errorCode});
            return;
        },
    };
    
    std.debug.print("\nParsed: {any}\n", .{patchedItem});

    const resultDel = try containerSO.deleteItem(&id, &id);
    const resultDelItem = switch (resultDel) {
        .Ok => resultDel.Ok,
        .Error => {
            std.debug.print("\nDelete Error: {s}\n", .{resultDel.Error.errorCode});
            return;
        },
    };

    _ = resultDelItem;

}
