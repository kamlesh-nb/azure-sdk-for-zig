const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "azcore",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("azcore", .{
        .root_source_file = .{ .path = "src/root.zig" },
        .imports = &.{
            .{
                .name = "datetime",
                .module = b.dependency("datetime", .{}).module("datetime"),
            },
            .{
                .name = "fetch",
                .module = b.dependency("fetch", .{}).module("fetch"),
            },
            .{
                .name = "http",
                .module = b.dependency("http", .{}).module("http"),
            },
            .{
                .name = "tls",
                .module = b.dependency("tls", .{}).module("tls"),
            },
        },
    });

    lib.root_module.addImport("datetime", b.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    }).module("datetime"));

    lib.root_module.addImport("fetch", b.dependency("fetch", .{
        .target = target,
        .optimize = optimize,
    }).module("fetch"));

    lib.root_module.addImport("http", b.dependency("http", .{
        .target = target,
        .optimize = optimize,
    }).module("http"));

    lib.root_module.addImport("tls", b.dependency("tls", .{
        .target = target,
        .optimize = optimize,
    }).module("tls"));

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "azcore",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("datetime", b.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    }).module("datetime"));

    exe.root_module.addImport("fetch", b.dependency("fetch", .{
        .target = target,
        .optimize = optimize,
    }).module("fetch"));

    exe.root_module.addImport("http", b.dependency("http", .{
        .target = target,
        .optimize = optimize,
    }).module("http"));

    exe.root_module.addImport("tls", b.dependency("tls", .{
        .target = target,
        .optimize = optimize,
    }).module("tls"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // const lib_unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/root.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
