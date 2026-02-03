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

//=============================================================================
// Additional String Operations Tests
//=============================================================================
test "trim" {
    try testing.expect(crz.streql(crz.trim("  hello  "), "hello"));
    try testing.expect(crz.streql(crz.trim("\t\nhello\n\t"), "hello"));
    try testing.expect(crz.streql(crz.trim("hello"), "hello"));
    try testing.expect(crz.streql(crz.trim(""), ""));
}

test "trim_left" {
    try testing.expect(crz.streql(crz.trim_left("  hello  "), "hello  "));
    try testing.expect(crz.streql(crz.trim_left("hello"), "hello"));
}

test "trim_right" {
    try testing.expect(crz.streql(crz.trim_right("  hello  "), "  hello"));
    try testing.expect(crz.streql(crz.trim_right("hello"), "hello"));
}

test "to_upper" {
    const allocator = testing.allocator;
    const upper = try crz.to_upper(allocator, "hello World 123");
    defer allocator.free(upper);
    try testing.expect(crz.streql(upper, "HELLO WORLD 123"));
}

test "to_lower" {
    const allocator = testing.allocator;
    const lower = try crz.to_lower(allocator, "HELLO World 123");
    defer allocator.free(lower);
    try testing.expect(crz.streql(lower, "hello world 123"));
}

test "contains" {
    try testing.expect(crz.contains("hello world", "world"));
    try testing.expect(crz.contains("hello world", "hello"));
    try testing.expect(!crz.contains("hello world", "foo"));
    try testing.expect(crz.contains("hello", ""));
}

test "starts_with" {
    try testing.expect(crz.starts_with("hello world", "hello"));
    try testing.expect(!crz.starts_with("hello world", "world"));
    try testing.expect(crz.starts_with("hello", ""));
}

test "ends_with" {
    try testing.expect(crz.ends_with("hello world", "world"));
    try testing.expect(!crz.ends_with("hello world", "hello"));
    try testing.expect(crz.ends_with("file.txt", ".txt"));
}

test "replace" {
    const allocator = testing.allocator;

    const r1 = try crz.replace(allocator, "hello world", "world", "zig");
    defer allocator.free(r1);
    try testing.expect(crz.streql(r1, "hello zig"));

    const r2 = try crz.replace(allocator, "aaa", "a", "bb");
    defer allocator.free(r2);
    try testing.expect(crz.streql(r2, "bbbbbb"));
}

test "repeat" {
    const allocator = testing.allocator;

    const r1 = try crz.repeat(allocator, "ab", 3);
    defer allocator.free(r1);
    try testing.expect(crz.streql(r1, "ababab"));

    const r2 = try crz.repeat(allocator, "x", 5);
    defer allocator.free(r2);
    try testing.expect(crz.streql(r2, "xxxxx"));

    const r3 = try crz.repeat(allocator, "test", 0);
    defer allocator.free(r3);
    try testing.expectEqual(@as(usize, 0), r3.len);
}

test "count_substr" {
    try testing.expectEqual(@as(usize, 2), crz.count_substr("abcabc", "abc"));
    try testing.expectEqual(@as(usize, 1), crz.count_substr("ababa", "aba"));
    try testing.expectEqual(@as(usize, 0), crz.count_substr("hello", "xyz"));
}

test "index_of" {
    try testing.expectEqual(@as(?usize, 2), crz.index_of("hello", "ll"));
    try testing.expectEqual(@as(?usize, 0), crz.index_of("hello", "he"));
    try testing.expectEqual(@as(?usize, null), crz.index_of("hello", "xyz"));
}

//=============================================================================
// Additional Mathematical Functions Tests
//=============================================================================
test "tan_f32" {
    const tolerance = 1e-4;
    try testing.expectApproxEqAbs(@as(f32, 0.0), crz.tan_f32(0.0), tolerance);
    // tan(pi/4) = 1.0
    try testing.expectApproxEqAbs(@as(f32, 1.0), crz.tan_f32(std.math.pi / 4.0), tolerance);
}

test "tan_f64" {
    const tolerance = 1e-8;
    try testing.expectApproxEqAbs(@as(f64, 0.0), crz.tan_f64(0.0), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 1.0), crz.tan_f64(std.math.pi / 4.0), tolerance);
}

test "min and max" {
    try testing.expectEqual(@as(i32, 3), crz.min(@as(i32, 5), @as(i32, 3)));
    try testing.expectEqual(@as(i32, 5), crz.max(@as(i32, 5), @as(i32, 3)));
    try testing.expectApproxEqAbs(@as(f64, 1.5), crz.min(@as(f64, 1.5), @as(f64, 2.5)), 1e-10);
    try testing.expectApproxEqAbs(@as(f64, 2.5), crz.max(@as(f64, 1.5), @as(f64, 2.5)), 1e-10);
}

test "clamp" {
    try testing.expectEqual(@as(i32, 10), crz.clamp(@as(i32, 15), 0, 10));
    try testing.expectEqual(@as(i32, 0), crz.clamp(@as(i32, -5), 0, 10));
    try testing.expectEqual(@as(i32, 5), crz.clamp(@as(i32, 5), 0, 10));
}

test "factorial" {
    try testing.expectEqual(@as(u64, 1), crz.factorial(0));
    try testing.expectEqual(@as(u64, 1), crz.factorial(1));
    try testing.expectEqual(@as(u64, 120), crz.factorial(5));
    try testing.expectEqual(@as(u64, 3628800), crz.factorial(10));
}

test "gcd" {
    try testing.expectEqual(@as(i32, 6), crz.gcd(@as(i32, 48), @as(i32, 18)));
    try testing.expectEqual(@as(i32, 1), crz.gcd(@as(i32, 17), @as(i32, 13)));
    try testing.expectEqual(@as(i32, 5), crz.gcd(@as(i32, 0), @as(i32, 5)));
}

test "lcm" {
    try testing.expectEqual(@as(i32, 12), crz.lcm(@as(i32, 4), @as(i32, 6)));
    try testing.expectEqual(@as(i32, 15), crz.lcm(@as(i32, 3), @as(i32, 5)));
    try testing.expectEqual(@as(i32, 0), crz.lcm(@as(i32, 0), @as(i32, 5)));
}

test "is_prime" {
    try testing.expect(!crz.is_prime(0));
    try testing.expect(!crz.is_prime(1));
    try testing.expect(crz.is_prime(2));
    try testing.expect(crz.is_prime(3));
    try testing.expect(!crz.is_prime(4));
    try testing.expect(crz.is_prime(17));
    try testing.expect(!crz.is_prime(18));
    try testing.expect(crz.is_prime(97));
}

test "deg_to_rad and rad_to_deg" {
    const tolerance = 1e-6;
    try testing.expectApproxEqAbs(@as(f64, std.math.pi), crz.deg_to_rad(@as(f64, 180.0)), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 180.0), crz.rad_to_deg(@as(f64, std.math.pi)), tolerance);
    try testing.expectApproxEqAbs(@as(f64, std.math.pi / 2.0), crz.deg_to_rad(@as(f64, 90.0)), tolerance);
}

test "lerp and inv_lerp" {
    const tolerance = 1e-10;
    try testing.expectApproxEqAbs(@as(f64, 5.0), crz.lerp(@as(f64, 0.0), @as(f64, 10.0), @as(f64, 0.5)), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 0.0), crz.lerp(@as(f64, 0.0), @as(f64, 10.0), @as(f64, 0.0)), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 10.0), crz.lerp(@as(f64, 0.0), @as(f64, 10.0), @as(f64, 1.0)), tolerance);

    try testing.expectApproxEqAbs(@as(f64, 0.5), crz.inv_lerp(@as(f64, 0.0), @as(f64, 10.0), @as(f64, 5.0)), tolerance);
}

test "map_range" {
    const tolerance = 1e-10;
    try testing.expectApproxEqAbs(@as(f64, 50.0), crz.map_range(@as(f64, 5.0), @as(f64, 0.0), @as(f64, 10.0), @as(f64, 0.0), @as(f64, 100.0)), tolerance);
    try testing.expectApproxEqAbs(@as(f64, 0.5), crz.map_range(@as(f64, 50.0), @as(f64, 0.0), @as(f64, 100.0), @as(f64, 0.0), @as(f64, 1.0)), tolerance);
}

test "sign" {
    try testing.expectEqual(@as(i32, 1), crz.sign(@as(i32, 42)));
    try testing.expectEqual(@as(i32, -1), crz.sign(@as(i32, -42)));
    try testing.expectEqual(@as(i32, 0), crz.sign(@as(i32, 0)));
}

//=============================================================================
// Additional File Operations Tests
//=============================================================================
test "write_file and file_size" {
    const test_path = "test_output.txt";
    const content = "Hello, CRZLib!";

    // Write file
    try crz.write_file(test_path, content);

    // Check file exists
    try testing.expect(crz.is_file(test_path));

    // Check file size
    const size = try crz.file_size(test_path);
    try testing.expectEqual(@as(u64, content.len), size);

    // Cleanup
    try std.fs.cwd().deleteFile(test_path);
}

test "append_file" {
    const test_path = "test_append.txt";

    // Write initial content
    try crz.write_file(test_path, "Line1\n");
    try crz.append_file(test_path, "Line2\n");

    // Check size increased
    const size = try crz.file_size(test_path);
    try testing.expectEqual(@as(u64, 12), size);

    // Cleanup
    try std.fs.cwd().deleteFile(test_path);
}

test "exists" {
    try testing.expect(crz.exists("build.zig"));
    try testing.expect(crz.exists("."));
    try testing.expect(!crz.exists("nonexistent_path_12345"));
}

//=============================================================================
// Array/Slice Utilities Tests
//=============================================================================
test "sum" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try testing.expectEqual(@as(i32, 15), crz.sum(&arr));

    const empty = [_]i32{};
    try testing.expectEqual(@as(i32, 0), crz.sum(&empty));
}

test "avg" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try testing.expectApproxEqAbs(@as(f64, 3.0), crz.avg(&arr), 1e-10);

    const empty = [_]i32{};
    try testing.expectEqual(@as(f64, 0), crz.avg(&empty));
}

test "reverse" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    crz.reverse(&arr);
    try testing.expectEqual(@as(i32, 5), arr[0]);
    try testing.expectEqual(@as(i32, 4), arr[1]);
    try testing.expectEqual(@as(i32, 3), arr[2]);
    try testing.expectEqual(@as(i32, 2), arr[3]);
    try testing.expectEqual(@as(i32, 1), arr[4]);
}

test "binary_search" {
    const arr = [_]i32{ 1, 3, 5, 7, 9, 11, 13 };
    try testing.expectEqual(@as(?usize, 2), crz.binary_search(&arr, 5));
    try testing.expectEqual(@as(?usize, 0), crz.binary_search(&arr, 1));
    try testing.expectEqual(@as(?usize, 6), crz.binary_search(&arr, 13));
    try testing.expectEqual(@as(?usize, null), crz.binary_search(&arr, 4));
    try testing.expectEqual(@as(?usize, null), crz.binary_search(&arr, 100));
}

test "slice_min and slice_max" {
    const arr = [_]i32{ 5, 2, 8, 1, 9, 3 };
    try testing.expectEqual(@as(?i32, 1), crz.slice_min(&arr));
    try testing.expectEqual(@as(?i32, 9), crz.slice_max(&arr));

    const empty = [_]i32{};
    try testing.expectEqual(@as(?i32, null), crz.slice_min(&empty));
    try testing.expectEqual(@as(?i32, null), crz.slice_max(&empty));
}

//=============================================================================
// Additional Random Number Generation Tests
//=============================================================================
test "rng_f32" {
    for (0..10) |_| {
        const f = crz.rng_f32();
        try testing.expect(f >= 0.0 and f < 1.0);
    }
}

test "rng_f64" {
    for (0..10) |_| {
        const f = crz.rng_f64();
        try testing.expect(f >= 0.0 and f < 1.0);
    }
}

test "rng_f32_range" {
    for (0..10) |_| {
        const f = crz.rng_f32_range(5.0, 10.0);
        try testing.expect(f >= 5.0 and f < 10.0);
    }
}

test "rng_f64_range" {
    for (0..10) |_| {
        const f = crz.rng_f64_range(5.0, 10.0);
        try testing.expect(f >= 5.0 and f < 10.0);
    }
}

test "rng_bool" {
    // Just ensure it doesn't crash and returns valid booleans
    var true_count: usize = 0;
    for (0..100) |_| {
        if (crz.rng_bool()) true_count += 1;
    }
    // Should have some variation (very unlikely to get 0 or 100 all same)
    try testing.expect(true_count > 0 and true_count < 100);
}

test "shuffle" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    const original_sum = crz.sum(&arr);
    crz.shuffle(&arr);
    // Sum should remain the same (elements just reordered)
    try testing.expectEqual(original_sum, crz.sum(&arr));
}

test "rng_choice" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };
    for (0..10) |_| {
        const choice = crz.rng_choice(&arr);
        try testing.expect(choice != null);
        // Check it's one of the valid values
        var found = false;
        for (arr) |item| {
            if (item == choice.?) {
                found = true;
                break;
            }
        }
        try testing.expect(found);
    }

    const empty = [_]i32{};
    try testing.expectEqual(@as(?i32, null), crz.rng_choice(&empty));
}

//=============================================================================
// Bit Manipulation Tests
//=============================================================================
test "popcount" {
    try testing.expectEqual(@as(u32, 3), crz.popcount(@as(u8, 0b10110)));
    try testing.expectEqual(@as(u32, 8), crz.popcount(@as(u8, 0xFF)));
    try testing.expectEqual(@as(u32, 0), crz.popcount(@as(u8, 0)));
}

test "leading_zeros" {
    try testing.expectEqual(@as(u32, 4), crz.leading_zeros(@as(u8, 0b00001000)));
    try testing.expectEqual(@as(u32, 0), crz.leading_zeros(@as(u8, 0b10000000)));
    try testing.expectEqual(@as(u32, 8), crz.leading_zeros(@as(u8, 0)));
}

test "trailing_zeros" {
    try testing.expectEqual(@as(u32, 3), crz.trailing_zeros(@as(u8, 0b00001000)));
    try testing.expectEqual(@as(u32, 0), crz.trailing_zeros(@as(u8, 0b00000001)));
}

test "is_power_of_two" {
    try testing.expect(crz.is_power_of_two(@as(u32, 1)));
    try testing.expect(crz.is_power_of_two(@as(u32, 2)));
    try testing.expect(crz.is_power_of_two(@as(u32, 4)));
    try testing.expect(crz.is_power_of_two(@as(u32, 8)));
    try testing.expect(!crz.is_power_of_two(@as(u32, 0)));
    try testing.expect(!crz.is_power_of_two(@as(u32, 3)));
    try testing.expect(!crz.is_power_of_two(@as(u32, 6)));
}

test "next_power_of_two" {
    try testing.expectEqual(@as(u32, 1), crz.next_power_of_two(@as(u32, 0)));
    try testing.expectEqual(@as(u32, 1), crz.next_power_of_two(@as(u32, 1)));
    try testing.expectEqual(@as(u32, 4), crz.next_power_of_two(@as(u32, 3)));
    try testing.expectEqual(@as(u32, 8), crz.next_power_of_two(@as(u32, 5)));
    try testing.expectEqual(@as(u32, 8), crz.next_power_of_two(@as(u32, 8)));
    try testing.expectEqual(@as(u32, 16), crz.next_power_of_two(@as(u32, 9)));
}
