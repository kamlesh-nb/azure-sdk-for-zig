const std = @import("std");
const Cosmos = @import("cosmos.zig");

const Database = @This();

id: []const u8,
client: *Cosmos = undefined,


pub fn init(d: []const u8, client: *Cosmos) Database {
    return Database{
        .id = d,
        .client = client,
    };
}


pub fn get(id: []const u8) Database {
    _ = id;
     
}

pub fn create(id: []const u8) Database {
    _ = id;
     
}

pub fn delete(id: []const u8) Database {
    _ = id;
     
}


pub fn all(id: []const u8) Database {
    _ = id;
     
}