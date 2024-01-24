const std = @import("std");
const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");
const E = @import("enums.zig");
const ResourceType = E.ResourceType;

const PartitionKeyPolicy = @import("policies/partition_key_policy.zig");
const ThroughputPolicy = @import("policies/throughput_policy.zig");
const MaxItemPolicy = @import("policies/max_item_policy.zig");

const core = @import("azcore");

const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;

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

pub const Container = struct {
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

    pub fn createItem(self: *Container, client: *CosmosClient, db: []const u8,  comptime T: type, payload: anytype, partitionKey: []const u8) !T {
        var resourceType: [2048]u8 = undefined;
        const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs", .{ db, self.id });

        var resourceLink: [2048]u8 = undefined;
        const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ db, self.id });

        try client.reinitPipeline();

        var pkp = PartitionKeyPolicy.new(partitionKey);
        try client.pipeline.?.policies.add(pkp.policy());

        var request = try client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

        try request.body.set(payload);

        var buf: [6]u8 = undefined;
        const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});
        
        request.parts.headers.add("Content-Length", str[0..str.len]);

        var response = try client.send(ResourceType.docs, rl[0..rl.len], &request);

        client.pipeline.?.deinit();

        // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
        return try response.body.get(client.allocator, T);

    }

    pub fn readItem(comptime T: type, client: *CosmosClient) !type {
        _ = T;
        _ = client;
    }

    pub fn readItems(comptime T: type, client: *CosmosClient) ![]type {
        _ = T;
        _ = client;
    }

    pub fn updateDocument(comptime T: type, client: *CosmosClient) !type {
        _ = T;
        _ = client;
    }

    pub fn deleteDocument(comptime T: type, client: *CosmosClient) !type {
        _ = T;
        _ = client;
    }
};
