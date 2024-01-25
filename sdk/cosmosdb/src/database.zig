const std = @import("std");
const CosmosClient = @import("cosmos.zig");
const Container = @import("container.zig");
const E = @import("enums.zig");
const ResourceType = E.ResourceType;
const DatabaseResponse = @import("resources/database.zig").DatabaseResponse;
const ContainerResponse = @import("resources/container.zig").ContainerResponse;
const Containers = @import("resources/container.zig").Containers;

const core = @import("azcore");

const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;

const Database = @This();


client: *CosmosClient,
db: DatabaseResponse,

pub fn getContainer(self: *Database, id: []const u8) !Container {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}", .{ self.db.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.id, id });
    try self.client.reinitPipeline();
    var request = try self.client.createRequest(rt[0..rt.len], Method.get, Version.Http11);

    var response = try self.client.send(ResourceType.colls, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    const containter = try response.body.get(self.client.allocator, ContainerResponse);

    return Container{ .client = self.client, .db = self, .container = containter };
}

pub fn getContainers(self: *Database) !Containers {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls", .{self.db.id});

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls", .{self.db.id});

    try self.client.reinitPipeline();

    var request = try self.client.createRequest(rt[0..rt.len], Method.get, Version.Http11);

    var response = try self.client.send(ResourceType.colls, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    return try response.body.get(self.client.allocator, Containers);

}

pub fn createContainer(self: *Database, id: []const u8, partitionKey: []const u8) !Container {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls", .{self.db.id});

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}", .{self.db.id});

    try self.client.reinitPipeline();

    var request = try self.client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

    const payload = .{
        .id = id,
        .indexingPolicy = .{
            .automatic = true,
            .indexingMode = "Consistent",
            .includedPaths = .{
                .{
                    .path = "/*",
                    .indexes = .{
                        .{
                            .dataType = "String",
                            .precision = -1,
                            .kind = "Range",
                        },
                    },
                },
            },
        },
        .partitionKey = .{
            .paths = .{
                partitionKey,
            },
            .kind = "Hash",
            .Version = 2,
        },
    };

    try request.body.set(payload);

    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try self.client.send(ResourceType.colls, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});

    const contnr = try response.body.get(self.client.allocator, ContainerResponse);

    return Container{ .client = self.client, .db = self, .container = contnr };
}

pub fn deleteContainer(self: *Database, id: []const u8, client: *CosmosClient) Container {
    _ = client;
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}", .{ self.db.id, id });

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{ self.db.id, id });

    try self.client.reinitPipeline();

    var request = try self.client.createRequest(rt[0..rt.len], Method.delete, Version.Http11);

    var response = try self.client.send(ResourceType.colls, rl[0..rl.len], &request);

    self.client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});

    const contnr = try response.body.get(self.client.allocator, ContainerResponse);

    return Container{ .client = self.client, .db = self, .container = contnr };
}
