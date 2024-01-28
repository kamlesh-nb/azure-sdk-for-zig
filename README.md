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

const cosmos = @import("azcosmos");

const CosmosClient = cosmos.CosmosClient;
const Database = cosmos.Database;

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

    var db = try client.createDatabase("floki");

    var container = try db.createContainer("SaleOrder", "/id");

    const saleOrder = .{
        .id = "170",
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
    std.debug.print("Created item:\n{any}", .{item});
}

```
