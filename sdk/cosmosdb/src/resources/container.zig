const std = @import("std");

pub const KeyKind = enum(u8) {
    Hash,
    Range,
    Spatial,
};

pub const DataType = enum(u8) {
    String,
    Number,
    Point,
    Polygon,
    LineString,
};

pub const IndexingMode = enum(u8) {
    Consistent,
    Lazy,
    None,
};

pub const IncludedPathIndex = struct {
    data_type: DataType,
    precision: ?i8,
    kind: KeyKind,
};

pub const IncludedPath = struct {
    path: []const u8,
    indexes: ?[]IncludedPathIndex,
};

pub const ExcludedPath = struct {
    path: []const u8,
};

pub const IndexingPolicy = struct {
    automatic: bool,
    indexing_mode: IndexingMode,
    included_paths: []IncludedPath,
    excluded_paths: []ExcludedPath,
};

pub const PartitionKey = struct {
    paths: [][]const u8,
    kind: KeyKind,
};

pub const ContainerResponse = struct {
    id: []const u8,
    indexing_policy: IndexingPolicy,
    parition_key: PartitionKey,
    _rid: []const u8,
    _ts: u64,
    _self: []const u8,
    _etag: []const u8,
    _docs: []const u8,
    _sprocs: []const u8,
    _triggers: []const u8,
    _udfs: []const u8,
    _conflicts: []const u8,
};
