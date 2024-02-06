const std = @import("std");
const CosmosClient = @import("cosmos.zig");
const Database = @import("database.zig");
const E = @import("enums.zig");
const ResourceType = E.ResourceType;
const ContainerResponse = @import("resources/container.zig").ContainerResponse;
const hasError = @import("errors.zig").hasError;
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
const Status = core.Status;

const ApiResponse = core.ApiResponse;
const Opaque = core.Opaque;
const ApiError = core.ApiError;

const Container = @This();

client: *CosmosClient,
db: *Database,
container: ContainerResponse,



fn itemResponse(self: *Container, hasErr: bool, response: *Response, comptime T: type) anyerror!ApiResponse(T) {
    if (hasErr) {
        return ApiResponse(T){
            .Error = .{
                .status = @intFromEnum(response.parts.status),
                .errorCode = response.parts.status.toString(),
                .rawResponse = response.body.buffer.str(),
            },
        };
    } else {
        return ApiResponse(T){
            .Ok = if (response.body.buffer.size > 0) try response.body.get(self.client.allocator, T) else T{},
        };
    }
}

pub fn createItem(self: *Container, comptime T: type, payload: anytype, partitionKey: []const u8) anyerror!ApiResponse(T) {
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

    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, T);
}

pub fn readItem(self: *Container, comptime T: type, item_id: []const u8, partitionKey: []const u8) anyerror!ApiResponse(T) {
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

    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, T);
}

pub fn updateItem(self: *Container, comptime T: type, payload: T, id: []const u8, partitionKey: []const u8) anyerror!ApiResponse(T) {
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

    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, T);
}

pub fn deleteItem(self: *Container, id: []const u8, partitionKey: []const u8) !ApiResponse(Opaque) {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.delete, Version.Http11);

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, Opaque);
}

pub fn queryItems(self: *Container, comptime T: type, query: anytype) anyerror!ApiResponse(T) {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs", .{ self.db.db.id, self.container.id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.db.id, self.container.id });

    try self.client.reinitPipeline();

    var mip = MaxItemPolicy.new(10);
    try self.client.pipeline.?.policies.add(mip.policy());

    var cpq = CrossPartitionQueryPolicy.new("True");
    try self.client.pipeline.?.policies.add(cpq.policy());

    var qp = QueryPolicy.new("True");
    try self.client.pipeline.?.policies.add(qp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

    try request.body.set(query);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    request.parts.headers.add("Content-Type", "application/query+json");

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, T);
}

pub fn patchItem(self: *Container, comptime T: type, id: []const u8, partitionKey: []const u8, patch: anytype) anyerror!ApiResponse(T) {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}/docs/{s}", .{ self.db.db.id, self.container.id, id });

    try self.client.reinitPipeline();

    var pkp = PartitionKeyPolicy.new(partitionKey);
    try self.client.pipeline.?.policies.add(pkp.policy());

    var request = try self.client.createRequest(rt[0..rt.len], Method.patch, Version.Http11);

    try request.body.set(patch);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    request.parts.headers.add("Content-Type", "application/query+json");

    var response = try self.client.send(ResourceType.docs, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();
    std.debug.print("\nPATCH ITEM RESPONSE: {s}\n", .{response.body.buffer.str()});
    return self.itemResponse(hasError(request.parts.method, response.parts.status), &response, T);
}
