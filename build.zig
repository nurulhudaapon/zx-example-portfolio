const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zigx_nuhu_dev", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    setupZigx(b, .{
        .target = target,
        .optimize = optimize,
    }, mod);

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

fn setupZigx(b: *std.Build, module_opts: std.Build.Module.CreateOptions, root_module: *std.Build.Module) void {
    // Get the dependencies
    const httpz_dep = b.dependency("httpz", .{
        .target = module_opts.target,
        .optimize = module_opts.optimize,
    });

    const zigx_dep = b.dependency("zigx_prototype", .{
        .target = module_opts.target,
        .optimize = module_opts.optimize,
    });

    // --- 1. Get the zigx executable artifact ---
    const zigx_exe = zigx_dep.artifact("zigx_prototype");

    // --- 2. Define the transpilation run command ---
    // This command generates the missing files in 'site/.zigx'
    const transpile_cmd = b.addRunArtifact(zigx_exe);
    transpile_cmd.addArgs(&[_][:0]const u8{
        "transpile",
        "site",
        "--output",
        "site/.zigx",
    });
    // Ensure the build fails if transpilation fails
    // transpile_cmd.expect_exit_code = 0;

    // --- 3. Define the main executable artifact ---
    const exe = b.addExecutable(.{
        .name = "www_zigx_nuhu_dev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("site/main.zig"),
            .target = module_opts.target,
            .optimize = module_opts.optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = root_module },
            },
        }),
    });

    // NEW FIX: Add the project root path (where 'site' is located) as an
    // include path to help the compiler resolve paths to generated files
    // once the transpilation step has completed.
    exe.addIncludePath(b.path("."));

    exe.root_module.addImport("httpz", httpz_dep.module("httpz"));
    exe.root_module.addImport("zx", zigx_dep.module("zx"));

    // CRITICAL FIX: Force the compilation of the main executable to wait
    // until the transpilation command has completed and generated all files.
    exe.step.dependOn(&transpile_cmd.step);

    b.installArtifact(exe);

    // --- 4. Define the explicit 'transpile' step ---
    const transpile_step = b.step("transpile", "Transpile ZigX components before running");
    transpile_step.dependOn(&transpile_cmd.step);

    // --- 5. Define the 'serve' step ---
    const run_step = b.step("serve", "Run the ZigX website");
    const run_cmd = b.addRunArtifact(exe);

    // Ensure running (serving) also depends on transpilation finishing first.
    run_cmd.step.dependOn(&transpile_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);

    if (b.args) |args| run_cmd.addArgs(args);
}
