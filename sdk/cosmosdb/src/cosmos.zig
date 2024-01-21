const std = @import("std");

const core = @import("azcore");
const Policy = core.Policy;
const Pipleline = core.Pipeline;
const ClientOptions = core.ClientOptions;
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const Database = @import("database.zig");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Method = http.Method;
const Version = http.Version;

const CosmosClient = @This();

allocator: std.mem.Allocator = undefined,
pipeline: Pipleline = undefined,
account: []const u8,
key: []const u8,
auth_token: []const u8 = undefined,
timestamp: []const u8 = undefined,

pub fn init(arena: *std.heap.ArenaAllocator, account: []const u8, key: []const u8) !CosmosClient {
    const allocator = arena.allocator();
    return .{
        .allocator = allocator,
        .pipeline = try Pipleline.init(allocator),
        .account = account,
        .key = key,
    };
}

pub fn authToken(client: *CosmosClient, verb: Method, resourceType: E.ResourceType, resourceLink: []const u8) !void {
    const authorization = try Authorization.init(client.allocator);
    defer Authorization.deinit();

    try authorization.genAuthSig(verb, resourceType, resourceLink, client.key);
    client.timestamp = authorization.timeStamp;
    client.auth_token = try authorization.auth.getWritten();
}

pub fn getDatabase(client: *CosmosClient, id: []const u8) Database {
    return Database.init(id, client);
}

pub fn request(client: *CosmosClient, resource: []const u8, verb: Method, version: Version) !Request {
    var location: [256]u8 = undefined;

    const uri = std.Uri{
        .scheme = "https",
        .host = std.fmt.bufPrint(&location, "{s}.documents.azure.com", .{client.account}),
        .port = 443,
        .fragment = null,
        .path = resource,
        .password = null,
        .query = null,
        .user = null,
    };

    return try Request.new(client.allocator, uri, verb, version);
}

pub fn deinit(client: *CosmosClient) void {
    client.pipeline.deinit();
}
