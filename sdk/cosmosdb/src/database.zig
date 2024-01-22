const std = @import("std");
const CosmosClient = @import("cosmos.zig");

const Database = @This();

id: []const u8,
_rid: []const u8,
_self: []const u8,
_etag: []const u8,
_ts: u64,
_colls: []const u8,
_users: []const u8,

pub fn init(id: []const u8, client: *CosmosClient) void {
    _ = client;
    _ = id;
    
}

pub fn getContainer(id: []const u8) Database {
    _ = id;
}

// pub fn createContainer(id: []const u8) Database {
//     _ = id;
// }

// pub fn deleteContainer(id: []const u8) Database {
//     _ = id;
// }

// pub fn all(id: []const u8) Database {
//     _ = id;
// }
