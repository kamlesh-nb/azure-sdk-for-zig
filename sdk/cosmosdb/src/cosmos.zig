const std = @import("std");
const core = @import("azcore");
const TelemetryPolicy = core.TelemetryPolicy;
const ApiVersionPolicy = core.ApiVersionPolicy;
const RequestDatePolicy = core.RequestDatePolicy;
const AuthorizationPolicy = core.AuthorizationPolicy;
const ActivityIdPolicy = core.ActivityIdPolicy;

const Policy = core.Policy;

const Pipleline = core.Pipeline;
const ClientOptions = core.ClientOptions;
const E = @import("enums.zig");
const CosmosErrors = @import("errors.zig").CosmosErrors;
const hasError = @import("errors.zig").hasError;

const ResourceType = E.ResourceType;
const Authorization = @import("authorization.zig");
const Database = @import("database.zig");
const DatabaseResponse = @import("resources/database.zig").DatabaseResponse;
const Buffer = core.Buffer;
const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;
const Status = core.Status;

const Result = core.Result;
const Opaque = core.Opaque;
const ApiError = core.ApiError;

pub const Databases = struct {
    _rid: []const u8,
    databases: []Database,
    _count: u32,
};

const CosmosClient = @This();

arena: *std.heap.ArenaAllocator = undefined,
allocator: std.mem.Allocator = undefined,
pipeline: ?Pipleline = null,
account: []const u8,
key: []const u8,
authorization: Authorization = undefined,
auth_token: []const u8 = undefined,
timestamp: []const u8 = undefined,
clientOptions: ClientOptions = undefined,
default_policies: usize = 0,

pub fn init(arena: *std.heap.ArenaAllocator, account: []const u8, key: []const u8) !CosmosClient {
    const allocator = arena.allocator();
    return CosmosClient{
        .arena = arena,
        .allocator = allocator,
        .clientOptions = try ClientOptions.new(allocator, "azure.cosmosdb.zig-v.0.01"),
        .account = account,
        .key = key,
    };
}

pub fn reinitPipeline(client: *CosmosClient) !void {
    if (client.pipeline) |_| {
        client.pipeline.?.deinit();
    }

    client.pipeline = try Pipleline.init(client.allocator);
}

pub fn send(client: *CosmosClient, resourceType: ResourceType, resourceLink: []const u8, request: *Request) !Response {
    client.authorization = try Authorization.init(client.allocator);
    defer client.authorization.deinit();
    try authToken(client, request.*.parts.method, resourceType, resourceLink);

    var rdp = RequestDatePolicy.new(client.authorization.timeStamp);
    try client.pipeline.?.policies.add(rdp.policy());

    var authp = AuthorizationPolicy.new(client.authorization.auth.str());
    try client.pipeline.?.policies.add(authp.policy());

    var actP = ActivityIdPolicy.new();
    try client.pipeline.?.policies.add(actP.policy());

    var tep = TelemetryPolicy.new("azure.cosmosdb.zig.v0.0.1");
    try client.pipeline.?.policies.add(tep.policy());

    var api = ApiVersionPolicy.new("2018-12-31");
    try client.pipeline.?.policies.add(api.policy());

    try client.pipeline.?.addDefaults(client.clientOptions);

    return try client.pipeline.?.send(client.arena, request);
}

fn authToken(client: *CosmosClient, verb: Method, resourceType: ResourceType, resourceLink: []const u8) !void {
    try client.authorization.genAuthSig(verb, resourceType, resourceLink, client.key);
}

pub fn getDatabase(client: *CosmosClient, id: []const u8) anyerror!Result(Database) {
    var resource: [2048]u8 = undefined;
    const r = try std.fmt.bufPrint(&resource, "/dbs/{s}", .{id});
    try client.reinitPipeline();
    var request = try createRequest(client, r[0..r.len], Method.get, Version.Http11);
    var response = try client.send(ResourceType.dbs, r[1..r.len], &request);

    client.pipeline.?.deinit();

    if (!hasError(request.parts.method, response.parts.status)) {
        return Result(Database){
            .value = Database{ .client = client, .db = try response.body.get(client.allocator, DatabaseResponse) },
            .errors = null,
        };
    } else {
        return Result(Database){
            .value = null,
            .errors = .{
                .status = @intFromEnum(response.parts.status),
                .errorCode = response.parts.status.toString(),
                .rawResponse = response.body.buffer.str(),
            },
        };
    }
}

pub fn createDatabase(client: *CosmosClient, id: []const u8) anyerror!Result(Database) {
    const payload = .{ .id = id };
    const r = "/dbs";
    try client.reinitPipeline();

    var request = try createRequest(client, r[0..r.len], Method.post, Version.Http11);

    try request.body.set(payload);
    std.debug.print("Payload: {s}\n", .{request.body.buffer.str()});
    var buf: [6]u8 = undefined;
    const str = try std.fmt.bufPrint(&buf, "{}", .{request.body.buffer.size});

    request.parts.headers.add("Content-Length", str[0..str.len]);

    var response = try client.send(ResourceType.dbs, "", &request);

    client.pipeline.?.deinit();

    if (!hasError(request.parts.method, response.parts.status)) {
        return Result(Database){
            .value = Database{ .client = client, .db = try response.body.get(client.allocator, DatabaseResponse) },
            .errors = null,
        };
    } else {
        return Result(Database){
            .value = null,
            .errors = .{
                .status = @intFromEnum(response.parts.status),
                .errorCode = response.parts.status.toString(),
                .rawResponse = response.body.buffer.str(),
            },
        };
    }
}

pub fn createRequest(client: *CosmosClient, path: []const u8, verb: Method, version: Version) !Request {
    const uri = std.Uri{
        .scheme = "https",
        .host = client.account,
        .port = 443,
        .fragment = null,
        .path = path,
        .password = null,
        .query = null,
        .user = null,
    };

    var req = try Request.new(client.allocator, uri, verb, version);

    req.parts.headers.add("Host", uri.host.?);
    req.parts.headers.add("Accept", "application/json");

    return req;
}

pub fn deinit(client: *CosmosClient) void {
    client.authorization.deinit();
    client.pipeline.deinit();
}
