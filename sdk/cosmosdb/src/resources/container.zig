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
    dataType: []const u8,
    precision: ?i8,
    kind: []const u8,
};

pub const IncludedPath = struct {
    path: []const u8,
};

pub const ExcludedPath = struct {
    path: []const u8,
};

pub const IndexingPolicy = struct {
    automatic: bool,
    indexingMode: []const u8,
    includedPaths: []IncludedPath,
    excludedPaths: []ExcludedPath,
};

pub const PartitionKey = struct {
    paths: [][]const u8,
    kind: []const u8,
    version: u8,
};

pub const ConflictResolutionPolicy = struct {
    mode: []const u8,
    conflictResolutionPath: []const u8,
    conflictResolutionProcedure: []const u8,
};

pub const GeospatialConfig = struct {
    type: []const u8,
};

pub const ContainerResponse = struct {
    id: []const u8,
    indexingPolicy: IndexingPolicy,
    partitionKey: PartitionKey,
    conflictResolutionPolicy: ConflictResolutionPolicy,
    geospatialConfig: GeospatialConfig,
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

pub const Containers = struct {
    _rid: []const u8,
    DocumentCollections: []ContainerResponse,
    _count: u64,
};
