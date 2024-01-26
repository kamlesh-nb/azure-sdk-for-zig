const std = @import("std");


pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "azcosmosdb",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("datetime", b.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    }).module("datetime"));


    lib.root_module.addImport("azcore", b.dependency("azcore", .{
        .target = target,
        .optimize = optimize,
    }).module("azcore"));

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "azcosmosdb",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("datetime", b.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    }).module("datetime"));

    exe.root_module.addImport("azcore", b.dependency("azcore", .{
        .target = target,
        .optimize = optimize,
    }).module("azcore"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("datetime", b.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    }).module("datetime"));

    tests.root_module.addImport("azcore", b.dependency("azcore", .{
        .target = target,
        .optimize = optimize,
    }).module("azcore"));

    const run_tests = b.addRunArtifact(tests);

     
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
 
}
