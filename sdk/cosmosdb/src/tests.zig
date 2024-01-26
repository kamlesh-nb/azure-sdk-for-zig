const std = @import("std");
const expect = std.testing.expect;

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

test "print test result" {
    const v = 3;
    try expect(v == 3);
    std.time.sleep(3000 * std.time.ns_per_ms);
}

test "db open" {
    var Arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer Arena.deinit();
    const allocator = Arena.allocator();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const account = env.get("COSMOSDB_ACCOUNT").?;
    const key = env.get("COSMOSDB_KEY").?;
    var client = try CosmosClient.init(&Arena, account, key);
    const db = try client.getDatabase("floki");
    expect(std.mem.eql(u8, db.db.id, "floki"));
}
