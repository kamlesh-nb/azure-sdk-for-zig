const std = @import("std");

pub const DatabaseResponse = struct {
    id: []const u8,
    _rid: []const u8,
    _ts: u64,
    _self: []const u8,
    _etag: []const u8,
    _colls: []const u8,
    _users: []const u8,
};
