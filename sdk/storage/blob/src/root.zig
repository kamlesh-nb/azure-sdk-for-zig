const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn Result(comptime T: type) type {
    return union(enum) {
        ok: T,
        err: T,
    };
}

const Entity = struct {
    id: u32,
    name: []const u8,
};

const Err = struct {
    code: u10,
    msg: []const u8,
};

test "union" {
     const entity = Entity{ .id = 11, .name = "hello" };
     _ = entity;
     const e = Err{ .code =201, .msg = "hello" };
     const result = Result(Err){ .err = e };
     switch (result) {
            .ok => {
                 try std.testing.expect(result.ok.id == 11);
            },
            .err => {
                 try std.testing.expect(result.err.code == 201);
            },
     }
    
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
