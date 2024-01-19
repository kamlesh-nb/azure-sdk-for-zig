const std = @import("std");
const HttpClient = @import("../http_client.zig");

const TransportOptions = @This();


timeout: u64,
httpClient: HttpClient,
 
