const std = @import("std");
const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");
const E = @import("enums.zig");
const ResourceType = E.ResourceType;

const ContainerResponse = @import("resources/container.zig").ContainerResponse;

const PartitionKeyPolicy = @import("policies/partition_key_policy.zig");
const ThroughputPolicy = @import("policies/throughput_policy.zig");
const MaxItemPolicy = @import("policies/max_item_policy.zig");
const CrossPartitionQueryPolicy = @import("policies/cross_partition_query_policy.zig");
const QueryPolicy = @import("policies/query_policy.zig");

const core = @import("azcore");

const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;

const Container = @This();

client: *CosmosClient,
db: *Database,
container: ContainerResponse,

pub fn createItem(self: *Container, comptime T: type, payload: anytype, partitionKey: []const u8) !T {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs", .{ self.db.db.id, self.container.id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.db.id, self.container.id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

    try request.body.set(payload);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    return try response.body.get(self.client.allocator, T);
}

pub fn readItem(self: *Container, comptime T: type, item_id: []const u8, partitionKey: []const u8) !type {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, item_id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, item_id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.get, Version.Http11);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    return try response.body.get(self.client.allocator, T);
}

pub fn readItems(self: *Container, comptime T: type) !T {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs", .{ self.db.db.id, self.container.id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.db.id, self.container.id });

    try self.client.reinitPipeline();

    var mip = MaxItemPolicy.new(10);
    try self.client.pipeline.?.policies.add(mip.policy());

    var cpq = CrossPartitionQueryPolicy.new("False");
    try self.client.pipeline.?.policies.add(cpq.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.get, Version.Http11);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    return try response.body.get(self.client.allocator, T);
}

pub fn updateDocument(self: *Container, comptime T: type, payload: T, id: []const u8, partitionKey: []const u8) !T {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.put, Version.Http11);

    try request.body.set(payload);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    return try response.body.get(self.client.allocator, T);
}

pub fn deleteDocument(self: *Container, id: []const u8, partitionKey: []const u8) !void {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.delete, Version.Http11);

    const response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);
    _ = response;

    self.client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    // return try response.body.get(self.client.allocator, T);
}

pub fn queryItems(self: *Container, comptime T: type, query: T) !T {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs", .{ self.db.db.id, self.container.id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.db.id, self.container.id });

    try self.client.reinitPipeline();

    var qp = QueryPolicy.new("True");
    try self.client.pipeline.?.policies.add(qp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

    try request.body.set(query);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    return try response.body.get(self.client.allocator, T);
}
