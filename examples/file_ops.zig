// MIT License - Copyright (c) 2024 CJ Remillard

/// File Operations Example
/// Demonstrates file reading, checking, and basic file operations using CRZLib
const crz = @import("crzlib");
const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    crz.log("=== CRZLib File Operations Example ===\n");

    // Check if files exist
    crz.log("Checking files and directories:");
    crz.strout("  build.zig exists: ");
    crz.logn(crz.is_file("build.zig"));

    crz.strout("  src/ is a directory: ");
    crz.logn(crz.is_dir("src"));

    crz.strout("  nonexistent.txt exists: ");
    crz.logn(crz.is_file("nonexistent.txt"));

    // Read a file
    crz.log("\nReading build.zig.zon:");
    const lines = crz.read_file(allocator, "build.zig.zon") catch |err| {
        crz.liberr("Failed to read file");
        crz.strout("Error: ");
        crz.logn(err);
        return err;
    };
    defer allocator.free(lines);

    crz.strout("  Lines read: ");
    crz.logn(lines.len);
    crz.log("\nFirst 5 lines:");
    for (lines[0..@min(5, lines.len)]) |line| {
        crz.strout("  ");
        crz.log(line);
    }

    crz.log("\nFile operations completed successfully!");
}
