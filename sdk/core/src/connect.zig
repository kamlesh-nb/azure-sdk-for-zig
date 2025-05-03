const std = @import("std");
const net = std.net;
const mem = std.mem;
const posix = std.posix;
const builtin = @import("builtin");

const native_os = builtin.os.tag;

const aio = @import("aio");
const coro = @import("coro");

pub const Connect = @This();

pub fn toAddress(addr: net.Address) !posix.socket_t {
    var socket: std.posix.socket_t = undefined;
    try coro.io.single(.socket, .{
        .domain = std.posix.AF.INET,
        .flags = std.posix.SOCK.STREAM | std.posix.SOCK.CLOEXEC,
        .protocol = std.posix.IPPROTO.TCP,
        .out_socket = &socket,
    });

    try coro.io.single(.connect, .{
        .socket = socket,
        .addr = &addr.any,
        .addrlen = addr.getOsSockLen(),
    });

    return socket;
}

pub fn toHost(allocator: mem.Allocator, hostname: []const u8, port: u16) !posix.socket_t {
    const list = try net.getAddressList(allocator, hostname, port);
    defer list.deinit();

    if (list.addrs.len == 0) return error.UnknownHostName;

    for (list.addrs, 0..list.addrs.len) |addr, i| {
        return toAddress(addr) catch |err| switch (err) {
            error.ConnectionRefused => {
                continue;
            },
            else => {
                if (i < list.addrs.len - 1) {
                    continue;
                } else {
                    return err;
                }
            },
        };
    }
    return posix.ConnectError.ConnectionRefused;
}

