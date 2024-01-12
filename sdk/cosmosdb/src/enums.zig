const std = @import("std");

pub const ResourceType = enum {
    dbs,
    colls,
    docs,
    sprocs,
    pkranges,
    pub fn toString(self: ResourceType) []const u8 {
        return switch (self) {
            .dbs => "dbs",
            .colls => "colls",
            .docs => "docs",
            .sprocs => "sprocs",
            .pkranges => "pkranges",
        };
    }
};

pub const DatabaseThoughputMode = enum {
    none,
    fixed,
    autopilot,
};