const std = @import("std");

pub const ApiError = struct {
    status: u10,
    errorCode: []const u8,
    rawResponse: []const u8,
};

pub fn Result(comptime T: type) type {
    return struct {
        value: ?T = null,
        errors: ?ApiError = null,
    };
}


pub const Opaque = struct{};

const TestEntity = struct {
    id: u64 = undefined,
    name: []const u8 = undefined,
};

fn testSendOk(comptime T: type) Result(T) {
    const entity = TestEntity{
        .id = 1,
        .name = "test",
    };
    return Result(T){
        .value = entity,
        .errors = null,
    };
}

fn testSendError(comptime T: type) Result(T) {
    const err = ApiError{
        .status = 500,
        .errorCode = "internal_error",
        .rawResponse = "internal server error",
    };
    return Result(T){
        .value = null,
        .errors = err,
    };
}

 

test "errors" {
    const result = testSendError(TestEntity);
    try std.testing.expect(result.value == null);
    try std.testing.expect(result.errors != null);
    try std.testing.expect(result.errors.?.status == 500);
    try std.testing.expect(std.mem.eql(u8, result.errors.?.errorCode, "internal_error")); //result.errors.errorCode == "internal_error");
    try std.testing.expect(std.mem.eql(u8, result.errors.?.rawResponse, "internal server error"));
}

 
test "ok" {
    const result = testSendOk(TestEntity);
    try std.testing.expect(result.value != null);
    try std.testing.expect(result.errors == null);
    try std.testing.expect(result.value.?.id == 1);
    try std.testing.expect(std.mem.eql(u8, result.value.?.name, "test"));
}

pub fn ApiResponse(comptime T: type) type {
    return union(enum) {
        const Self = @This();
        Ok: T,
        Error: ApiError,

        const Tag = @typeInfo(Self).Union.tag_type.?;

        fn fieldType(comptime kind: Tag) type {
            return std.meta.fields(Self)[@intFromEnum(kind)].field_type;
        }

        pub fn has(self: Self, comptime kind: Tag) bool {
            switch (self) {
                kind => return true,
                else => return false,
            }
        }

    };
}

fn testSendAROk(comptime T: type) ApiResponse(T) {
    const entity = TestEntity{
        .id = 1,
        .name = "test",
    };
    return ApiResponse(T){
        .Ok = entity,
    };
}

fn testSendARError(comptime T: type) ApiResponse(T) {
    const err = ApiError{
        .status = 500,
        .errorCode = "internal_error",
        .rawResponse = "internal server error",
    };
    return ApiResponse(T){
        .Error = err,
    };
}


test "apiresponseok" {
    const result = testSendAROk(TestEntity);
    try std.testing.expect(result.has(.Error) == false);
    try std.testing.expect(result.Ok.id == 1);
}

test "apiresponseerr" {
    const result = testSendARError(TestEntity);
    try std.testing.expect(result.has(.Ok) == false);
    try std.testing.expect(result.Error.status == 500);
    try std.testing.expect(std.mem.eql(u8, result.Error.errorCode, "internal_error"));
    try std.testing.expect(std.mem.eql(u8, result.Error.rawResponse, "internal server error"));
}
  