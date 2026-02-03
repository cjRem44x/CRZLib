const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the crzlib module
    const crzlib_module = b.addModule("crzlib", .{
        .root_source_file = b.path("src/crzlib.zig"),
    });

    // Unit tests
    const test_module = b.createModule(.{
        .root_source_file = b.path("tests/test_main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_module.addImport("crzlib", crzlib_module);

    const lib_tests = b.addTest(.{
        .root_module = test_module,
    });
    lib_tests.linkLibC();

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_tests.step);

    // Examples
    const examples = [_]struct { name: []const u8, desc: []const u8 }{
        .{ .name = "benchmark", .desc = "Run allocator benchmark" },
        .{ .name = "file_ops", .desc = "File operations example" },
        .{ .name = "string_ops", .desc = "String operations example" },
        .{ .name = "math_funcs", .desc = "Mathematical functions example" },
        .{ .name = "new_utils", .desc = "New utilities example" },
    };

    inline for (examples) |example| {
        const exe_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{example.name})),
            .target = target,
            .optimize = optimize,
        });
        exe_module.addImport("crzlib", crzlib_module);

        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = exe_module,
        });
        exe.linkLibC();

        const install_exe = b.addInstallArtifact(exe, .{});
        const exe_step = b.step(
            b.fmt("example-{s}", .{example.name}),
            b.fmt("Build and install {s} example", .{example.desc}),
        );
        exe_step.dependOn(&install_exe.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&install_exe.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(
            b.fmt("run-{s}", .{example.name}),
            b.fmt("Run {s} example", .{example.desc}),
        );
        run_step.dependOn(&run_cmd.step);
    }

    // Install all examples
    const examples_step = b.step("examples", "Build all examples");
    inline for (examples) |example| {
        const exe_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{example.name})),
            .target = target,
            .optimize = optimize,
        });
        exe_module.addImport("crzlib", crzlib_module);

        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = exe_module,
        });
        exe.linkLibC();
        const install_exe = b.addInstallArtifact(exe, .{});
        examples_step.dependOn(&install_exe.step);
    }
}
