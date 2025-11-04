const std = @import("std");
const zx = @import("zx");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zigx_nuhu_dev", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    // const zx_dep = b.dependency("zx", .{ .target = target, .optimize = optimize });
    zx.setup(b, .{
        .name = "www_zigx_nuhu_dev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("site/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = mod },
                // .{ .name = "zx", .module = zigx_dep.module("zx") },
            },
        }),
    });

    const exe = b.addExecutable(.{
        .name = "zigx_nuhu_dev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
