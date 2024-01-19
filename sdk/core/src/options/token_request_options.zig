const std = @import("std");

const TokenRequestOptions = @This();

claims: []const u8,
enableCAE: bool,
scopes: []const u8,
tenantID: []const u8,
