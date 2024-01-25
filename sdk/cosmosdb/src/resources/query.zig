const std = @import("std");

pub const Parameter = struct {
    name: []const u8,
    value: []const u8,
};

pub const Query = struct {
    query: []const u8,
    parameters: []Parameter,
};