const std = @import("std");
const CosmosClient = @import("cosmos.zig");
const Container = @import("container.zig").Container;
const E = @import("enums.zig");
const ResourceType = E.ResourceType;

const core = @import("azcore");

const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;

const Database = @This();

id: []const u8,
_rid: []const u8,
_self: []const u8,
_etag: []const u8,
_ts: u64,
_colls: []const u8,
_users: []const u8,

pub fn getContainer(self: *Database, client: *CosmosClient, id: []const u8) !Container {
  var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls/{s}", .{self.id, id});

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}/colls/{s}", .{self.id, id});
    try client.reinitPipeline();
    var request = try client.createRequest(rt[0..rt.len], Method.get, Version.Http11);

    var response = try client.send(ResourceType.colls, rl[0..rl.len],&request);

    client.pipeline.?.deinit();

    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});
    
    return response.body.get(client.allocator, Container);
}

pub fn getContainers(self: *Database, client: *CosmosClient) []Container {
    _ = self;
    _ = client;
}

pub fn createContainer(self: *Database, client: *CosmosClient, id: []const u8, partitionKey: []const u8) !Container {
    var resourceType: [2048]u8 = undefined;
    const rt = try std.fmt.bufPrint(&resourceType, "/dbs/{s}/colls", .{self.id});

    var resourceLink: [2048]u8 = undefined;
    const rl = try std.fmt.bufPrint(&resourceLink, "dbs/{s}", .{self.id});

    try client.reinitPipeline();

    var request = try client.createRequest(rt[0..rt.len], Method.post, Version.Http11);

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


    var response = try client.send(ResourceType.colls, rl[0..rl.len], &request);

    client.pipeline.?.deinit();
    
    // std.debug.print("\nResponse: \n{s}\n", .{response.body.buffer.str()});

    return try response.body.get(client.allocator, Container);
}

pub fn deleteContainer(self: *Database, id: []const u8, client: *CosmosClient) Container {
    _ = self;
    _ = client;
    _ = id;
}
