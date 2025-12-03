const crz = @import("crzlib");
const std = @import("std");
const testing = std.testing;

test "error reporting" {
    // Test that error reporting doesn't crash
    crz.liberr("Test error message");
}

test "command line arguments" {
    // Use page allocator since get_args needs to return memory that outlives the function
    const args = try crz.get_args(std.heap.page_allocator);
    defer {
        for (args) |arg| {
            std.heap.page_allocator.free(arg);
        }
        std.heap.page_allocator.free(args);
    }
    // Just verify we can get args without crashing
}

test "file existence checks" {
    // Test is_file
    try testing.expect(crz.is_file("build.zig"));
    try testing.expect(!crz.is_file("nonexistent_file.txt"));

    // Test is_dir
    try testing.expect(crz.is_dir("."));
    try testing.expect(!crz.is_dir("nonexistent_directory"));
}

test "read file" {
    const allocator = testing.allocator;
    const lines = try crz.read_file(allocator, "build.zig.zon");
    defer {
        for (lines) |line| {
            allocator.free(line);
        }
        allocator.free(lines);
    }

    try testing.expect(lines.len > 0);
}

test "string equality" {
    try testing.expect(crz.streql("hello", "hello"));
    try testing.expect(!crz.streql("hello", "world"));
    try testing.expect(crz.streql("", ""));
}

test "string concatenation" {
    const allocator = testing.allocator;
    const result = try crz.strcat(allocator, "Hello, ", "World!");
    defer allocator.free(result);

    try testing.expect(crz.streql(result, "Hello, World!"));
}

test "string splitting" {
    // strsplit uses page_allocator internally
    const parts = try crz.strsplit("a,b,c", ",");
    defer {
        for (parts) |part| {
            std.heap.page_allocator.free(part);
        }
        std.heap.page_allocator.free(parts);
    }

    try testing.expectEqual(@as(usize, 3), parts.len);
    try testing.expect(crz.streql(parts[0], "a"));
    try testing.expect(crz.streql(parts[1], "b"));
    try testing.expect(crz.streql(parts[2], "c"));
}

test "random number generation i32" {
    for (0..10) |_| {
        const num = crz.rng_i32(1, 100);
        try testing.expect(num >= 1 and num <= 100);
    }
}

test "random number generation i64" {
    for (0..10) |_| {
        const num = crz.rng_i64(1, 1000);
        try testing.expect(num >= 1 and num <= 1000);
    }
}

test "random number generation usize" {
    for (0..10) |_| {
        const num = crz.rng_usize(0, 50);
        try testing.expect(num <= 50);
    }
}

test "sqrt_f32" {
    try testing.expectApproxEqAbs(@as(f32, 0.0), crz.sqrt_f32(0.0), 1e-6);
    try testing.expectApproxEqAbs(@as(f32, 1.0), crz.sqrt_f32(1.0), 1e-6);
    try testing.expectApproxEqAbs(@as(f32, 2.0), crz.sqrt_f32(4.0), 1e-6);
    try testing.expectApproxEqAbs(@as(f32, 4.0), crz.sqrt_f32(16.0), 1e-6);
    try testing.expectApproxEqAbs(@as(f32, 10.0), crz.sqrt_f32(100.0), 1e-6);
}

test "sqrt_f64" {
    try testing.expectApproxEqAbs(@as(f64, 0.0), crz.sqrt_f64(0.0), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 1.0), crz.sqrt_f64(1.0), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 2.0), crz.sqrt_f64(4.0), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 4.0), crz.sqrt_f64(16.0), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 10.0), crz.sqrt_f64(100.0), 1e-10);
}

test "inv_sqrt_f32" {
    const tolerance = 1e-2; // Inverse sqrt is less precise
    try testing.expectApproxEqAbs(@as(f32, 0.25), crz.inv_sqrt_f32(16.0), tolerance);
    try testing.expectApproxEqAbs(@as(f32, 0.5), crz.inv_sqrt_f32(4.0), tolerance);
}

test "inv_sqrt_f64" {
    const tolerance = 1e-2;
    try testing.expectApproxEqAbs(@as(f64, 0.25), crz.inv_sqrt_f64(16.0), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 0.5), crz.inv_sqrt_f64(4.0), tolerance);
}

test "sin_f32" {
    const tolerance = 1e-4;
    try testing.expectApproxEqAbs(@as(f32, 0.0), crz.sin_f32(0.0), tolerance);
    try testing.expectApproxEqAbs(@as(f32, 1.0), crz.sin_f32(std.math.pi / 2.0), tolerance);
}

test "cos_f32" {
    const tolerance = 1e-4;
    try testing.expectApproxEqAbs(@as(f32, 1.0), crz.cos_f32(0.0), tolerance);
    try testing.expectApproxEqAbs(@as(f32, 0.0), crz.cos_f32(std.math.pi / 2.0), tolerance);
}

test "sin_f64" {
    const tolerance = 1e-8;
    try testing.expectApproxEqAbs(@as(f64, 0.0), crz.sin_f64(0.0), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 1.0), crz.sin_f64(std.math.pi / 2.0), tolerance);
}

test "cos_f64" {
    const tolerance = 1e-8;
    try testing.expectApproxEqAbs(@as(f64, 1.0), crz.cos_f64(0.0), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 0.0), crz.cos_f64(std.math.pi / 2.0), tolerance);
}

test "pow function" {
    try testing.expectEqual(@as(i32, 8), crz.pow(@as(i32, 2), 3));
    try testing.expectEqual(@as(i32, 25), crz.pow(@as(i32, 5), 2));
    try testing.expectEqual(@as(i32, 1), crz.pow(@as(i32, 10), 0));
    try testing.expectEqual(@as(f32, 1.0), crz.pow(@as(f32, 5.0), 0));
}

test "abs_f64" {
    try testing.expectEqual(@as(f64, 42.0), crz.abs_f64(-42.0));
    try testing.expectEqual(@as(f64, 42.0), crz.abs_f64(42.0));
    try testing.expectEqual(@as(f64, 0.0), crz.abs_f64(0.0));
}

test "number parsing - integers" {
    try testing.expectEqual(@as(i8, 42), crz.str_i8("42"));
    try testing.expectEqual(@as(i16, 1234), crz.str_i16("1234"));
    try testing.expectEqual(@as(i32, 12345), crz.str_i32("12345"));
    try testing.expectEqual(@as(i64, 123456), crz.str_i64("123456"));
    try testing.expectEqual(@as(i128, 1234567), crz.str_i128("1234567"));

    // Test invalid input returns 0
    try testing.expectEqual(@as(i32, 0), crz.str_i32("invalid"));
}

test "number parsing - floats" {
    try testing.expectApproxEqAbs(@as(f32, 3.14), crz.str_f32("3.14"), 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 3.14159), crz.str_f64("3.14159"), 1e-10);

    // Test invalid input returns 0.0
    try testing.expectEqual(@as(f64, 0.0), crz.str_f64("invalid"));
}

test "sleep functions" {
    // Just test that they don't crash
    crz.sleep_ms(1);
    crz.sleep_sec(0);
}
