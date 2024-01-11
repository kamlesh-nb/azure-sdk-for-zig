const std = @import("std");
const mem = std.mem;
const ascii = std.ascii;
const Allocator = std.mem.Allocator;

const Headers = @This();

pub const Header = struct {
    name: []const u8,
    value: []const u8,
};

len: usize,
keys: [][]const u8,
values: [][]const u8,

pub fn init(allocator: Allocator, max: usize) !Headers {
    const keys = try allocator.alloc([]const u8, max);
    const values = try allocator.alloc([]const u8, max);
    return Headers{
        .len = 0,
        .keys = keys,
        .values = values,
    };
}

pub fn deinit(self: *Headers, allocator: Allocator) void {
    allocator.free(self.keys);
    allocator.free(self.values);
}

pub fn add(self: *Headers, key: []const u8, value: []const u8) void {
    const len = self.len;
    var keys = self.keys;
    if (len == keys.len) {
        return;
    }

    keys[len] = key;
    self.values[len] = value;
    self.len = len + 1;
}

pub fn get(self: Headers, needle: []const u8) ?[]const u8 {
    const keys = self.keys[0..self.len];
    for (keys, 0..) |key, i| {
        if (mem.eql(u8, key, needle)) {
            return self.values[i];
        }
    }

    return null;
}

pub fn reset(self: *Headers) void {
    self.len = 0;
}

// Iterator support
pub usingnamespace struct {
    pub const HeadersIterator = struct {
        headers: *const Headers,
        index: usize,

        pub fn next(it: *HeadersIterator) ?Header {
            it.index = it.index + 1;

            if (it.headers.len > (it.index - 1)) {
                return Header{
                    .name = it.headers.keys[it.index - 1],
                    .value = it.headers.values[it.index - 1],
                };
            }
            return null;
        }
    };

    pub fn iterator(self: *const Headers) HeadersIterator {
        return HeadersIterator{
            .headers = self,
            .index = 0,
        };
    }
};

test "iterator" {
    var headers = try Headers.init(std.testing.allocator, 5);
    defer headers.deinit(std.testing.allocator);

    headers.add("e", "f");
    headers.add("a", "b");
    var it = headers.iterator();
    while (it.next()) |h| {
        std.debug.print("{?}", .{h});
    }
}
