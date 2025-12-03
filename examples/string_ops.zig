// MIT License - Copyright (c) 2024 CJ Remillard

/// String Operations Example
/// Demonstrates string manipulation functions from CRZLib
const crz = @import("crzlib");
const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    crz.log("=== CRZLib String Operations Example ===\n");

    // String equality
    crz.log("Testing string equality:");
    crz.strout("  'hello' == 'hello': ");
    crz.logn(crz.streql("hello", "hello"));
    crz.strout("  'hello' == 'world': ");
    crz.logn(crz.streql("hello", "world"));

    // String concatenation
    crz.log("\nTesting string concatenation:");
    const result1 = try crz.strcat(allocator, "Hello, ", "World!");
    defer allocator.free(result1);
    crz.strout("  'Hello, ' + 'World!' = ");
    crz.log(result1);

    const result2 = try crz.strcat(allocator, "Zig ", "is awesome");
    defer allocator.free(result2);
    crz.strout("  'Zig ' + 'is awesome' = ");
    crz.log(result2);

    // String splitting
    crz.log("\nTesting string splitting:");
    const parts1 = try crz.strsplit("apple,banana,cherry", ",");
    defer allocator.free(parts1);
    crz.log("  Split 'apple,banana,cherry' by ',':");
    for (parts1) |part| {
        crz.strout("    - ");
        crz.log(part);
    }

    const parts2 = try crz.strsplit("one::two::three", "::");
    defer allocator.free(parts2);
    crz.log("\n  Split 'one::two::three' by '::':");
    for (parts2) |part| {
        crz.strout("    - ");
        crz.log(part);
    }

    // Number parsing
    crz.log("\nTesting number parsing:");
    crz.strout("  str_i32('42') = ");
    crz.logn(crz.str_i32("42"));

    crz.strout("  str_f64('3.14159') = ");
    crz.logn(crz.str_f64("3.14159"));

    crz.strout("  str_i64('1000000') = ");
    crz.logn(crz.str_i64("1000000"));

    crz.log("\nString operations completed successfully!");
}
