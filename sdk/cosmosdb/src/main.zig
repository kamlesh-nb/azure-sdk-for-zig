const std = @import("std");
const E = @import("enums.zig");
const Authorization = @import("authorization.zig");
const http = @import("http");
const Method = http.Method;
const Request = http.Request;
const Response = http.Response;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }
    const allocator = gpa.allocator();

    var authorization = try Authorization.init(allocator);
    defer authorization.deinit();

    const chabi = "6MmwhrkzNbAqogOO3XLcs5wiVC3yXjLUs0mX2v6kWWTzf1i6RZsdikB9h1q7Qi4UBb3jX3uuhL3JACDbd2TTOg==";

    try authorization.genAuthSig(Method.get, E.ResourceType.dbs, "dbs/floki", chabi);
    const auth = try authorization.auth.getWritten();
    _ = auth;
    std.debug.print("\nSize: {d}\nSig: {s}\n", .{ authorization.auth.size, try authorization.auth.getWritten() });
}

test "auth" {
    var auth = try Authorization.init(std.testing.allocator);
    defer auth.deinit();

    const chabi = "==";
    try auth.genAuthSig(Method.get, E.ResourceType.dbs, "dbs/floki", chabi);

    std.debug.print("Sig: \n{s}", .{auth.auth});
}
