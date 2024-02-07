## Azure Sdk for Zig

> [!CAUTION]
> This is an experimental project and just meant to be used for experimenting zig on azure.

What's be developed as of now.

- Core Runtime that processes the request for Azure Rest Api's
- CosmosDb Client, that can;
  - Create, Get & Delete Database
  - Create, Get & Delete Container
  - Create, Read, Update, Delete & Patch Items
- If you would like to try CosmosDb Package in Zig, please refer cosmosdb folder sdk/samples or refer below code.

Here's a quick sample for connecting to Aziure CosmosDb, creating database, container in the database and an item in the container. You should have CosmosDb Account created in Azure to use below sample.

- Create a Zig executable project

```shell
    zig init
```

- Fetch CosmosDb package

```shell
    zig fetch --save https://github.com/kamlesh-nb/azure-sdk-for-zig/releases/download/6/azcosmosdb.tar.gz
```

```zig

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

    //this gets the database and creats it if it does not exist
    const db = try client.getDatabase("ziggy");

    var flokiDb = switch (db) {
        .Ok => db.Ok,
        .Error => {
            std.debug.print("\nDatabase: {s}\n", .{db.Error.rawResponse});
            return;
        },
    };

    //gets the container or creates if it does not exist
    const con = try flokiDb.getContainer("SaleOrder", "/id");

    var containerSO = switch (con) {
        .Ok => con.Ok,
        .Error => {
            std.debug.print("\nContainer: {s}\n{s}", .{con.Error.errorCode, con.Error.rawResponse});
            return;
        },
    };

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

    //creates item in the container
    const item = try containerSO.createItem(SaleOrder, saleOrder, &saleOrder.id);

    const createdItem = switch (item) {
        .Ok => item.Ok,
        .Error => {
            std.debug.print("\nItem Error: {s}\n", .{item.Error.errorCode});
            return;
        },
    };

    std.debug.print("\nItem Created: id = {s}\n", .{createdItem.id});

    //read item from the container based on the id amd partition key.
    const so = try containerSO.readItem(SaleOrder, &id, &id);

    const soItem = switch (so) {
        .Ok => so.Ok,
        .Error => {
            std.debug.print("\nItem Error: {s}\n", .{so.Error.errorCode});
            return;
        },
    };

    std.debug.print("\nItem Read: {any}\n", .{soItem});

    //query items in the container
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

        //update the item in the container
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
        .operations = .{ .{ .op = "replace", .path = "/RegionId", .value = "RU" }, .{
            .op = "add",
            .path = "/Items",
            .value = .{
                .{ .OrderQty = 1, .ProductId = 1, .UnitPrice = 1219.4589, .LineTotal = 1219.4589 },
                .{ .OrderQty = 1, .ProductId = 2, .UnitPrice = 219.4589, .LineTotal = 219.4589 },
                .{ .OrderQty = 1, .ProductId = 3, .UnitPrice = 319.4589, .LineTotal = 319.4589 },
            },
        } },
    };

    //patch the item in the container, use appropriate id and partition key
    const patchResult = try containerSO.patchItem(SaleOrder, "id", "partitionKey", patch);

    const patchedItem = switch (patchResult) {
        .Ok => patchResult.Ok,
        .Error => {
            std.debug.print("\nPatch Error: {s}\n", .{patchResult.Error.errorCode});
            return;
        },
    };

    std.debug.print("\nParsed: {any}\n", .{patchedItem});

    //delete the item in the container, uncomment the below code and pass the required  id and partition key

    // const resultDel = try containerSO.deleteItem("id", "partitionKey");
    // const resultDelItem = switch (resultDel) {
    //     .Ok => resultDel.Ok,
    //     .Error => {
    //         std.debug.print("\nDelete Error: {s}\n", .{resultDel.Error.errorCode});
    //         return;
    //     },
    // };

    // _ = resultDelItem;
}


```
