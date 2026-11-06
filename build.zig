const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dependency = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dependency.artifact("SDL3");

    const sdl_image_dependency = b.dependency("sdl_image", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_image_lib = sdl_image_dependency.artifact("SDL3_image");

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.addWriteFiles().add("stub.h",
            \\#include <SDL3/SDL.h>
            \\#include <SDL3_image/SDL_image.h>
        ),
        .target = target,
        .optimize = optimize,
    });
    translate_c.addIncludePath(sdl_lib.getEmittedIncludeTree());
    translate_c.addIncludePath(sdl_image_lib.getEmittedIncludeTree());

    const mod = b.addModule("g_engine", .{
        .root_source_file = b.path("src/engine/root.zig"),
        .target = target,
    });

    mod.addImport("sdl", translate_c.createModule());
    mod.linkLibrary(sdl_lib);
    mod.linkLibrary(sdl_image_lib);

    const exe = b.addExecutable(.{
        .name = "game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/game/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "g_engine", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    run_cmd.addPassthruArgs();

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
