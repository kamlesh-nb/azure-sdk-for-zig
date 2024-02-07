const std = @import("std");
const core = @import("azcore");

const Policy = core.Policy;
const TelemetryPolicy = core.TelemetryPolicy;
const ApiVersionPolicy = core.ApiVersionPolicy;
const RequestDatePolicy = core.RequestDatePolicy;
const AuthorizationPolicy = core.AuthorizationPolicy;


const Pipleline = core.Pipeline;
const ClientOptions = core.ClientOptions;
const Buffer = core.Buffer;
const Request = core.Request;
const Response = core.Response;
const Method = core.Method;
const Version = core.Version;

const BlobServiceClient = @This();



arena: *std.heap.ArenaAllocator = undefined,
allocator: std.mem.Allocator = undefined,
account: []const u8,
key: []const u8,
pipeline: ?Pipleline = null,
clientOptions: ClientOptions = undefined,

pub fn init(arena: *std.heap.ArenaAllocator, account: []const u8, key: []const u8) !BlobServiceClient {
    const allocator = arena.allocator();
    return BlobServiceClient{
        .arena = arena,
        .allocator = allocator,
        .clientOptions = try ClientOptions.new(allocator, "azure.storage.blob.zig-v.0.01"),
        .account = account,
        .key = key,
    };
}

pub fn send(client: *BlobServiceClient,  request: *Request) !Response {

    var rdp = RequestDatePolicy.new(client.authorization.timeStamp);
    try client.pipeline.?.policies.add(rdp.policy());

    var authp = AuthorizationPolicy.new(client.authorization.auth.str());
    try client.pipeline.?.policies.add(authp.policy());

    var tep = TelemetryPolicy.new("azure.blob.service.zig.v0.0.1");
    try client.pipeline.?.policies.add(tep.policy());

    var api = ApiVersionPolicy.new("2018-12-31");
    try client.pipeline.?.policies.add(api.policy());

    try client.pipeline.?.addDefaults(client.clientOptions);

    return try client.pipeline.?.send(client.arena, request);
}