// MIT License - Copyright (c) 2024 CJ Remillard

/// New Utilities Example
/// Demonstrates the additional utility functions added to CRZLib
const crz = @import("crzlib");
const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    crz.log("=== CRZLib New Utilities Example ===\n");

    // =========================================================================
    // String Operations
    // =========================================================================
    crz.log("--- String Operations ---\n");

    // Trim
    crz.log("Trim functions:");
    crz.strout("  trim('  hello  ') = '");
    crz.strout(crz.trim("  hello  "));
    crz.log("'");

    // Case conversion
    crz.log("\nCase conversion:");
    const upper = try crz.to_upper(allocator, "hello world");
    defer allocator.free(upper);
    crz.strout("  to_upper('hello world') = ");
    crz.log(upper);

    const lower = try crz.to_lower(allocator, "HELLO WORLD");
    defer allocator.free(lower);
    crz.strout("  to_lower('HELLO WORLD') = ");
    crz.log(lower);

    // String checks
    crz.log("\nString checks:");
    crz.strout("  contains('hello world', 'world') = ");
    crz.logn(crz.contains("hello world", "world"));
    crz.strout("  starts_with('hello.txt', 'hello') = ");
    crz.logn(crz.starts_with("hello.txt", "hello"));
    crz.strout("  ends_with('hello.txt', '.txt') = ");
    crz.logn(crz.ends_with("hello.txt", ".txt"));

    // Replace
    crz.log("\nString replace:");
    const replaced = try crz.replace(allocator, "hello world world", "world", "zig");
    defer allocator.free(replaced);
    crz.strout("  replace('hello world world', 'world', 'zig') = ");
    crz.log(replaced);

    // Repeat
    crz.log("\nString repeat:");
    const repeated = try crz.repeat(allocator, "ab", 5);
    defer allocator.free(repeated);
    crz.strout("  repeat('ab', 5) = ");
    crz.log(repeated);

    // Count and index
    crz.log("\nSubstring operations:");
    crz.strout("  count_substr('abcabc', 'abc') = ");
    crz.logn(crz.count_substr("abcabc", "abc"));
    crz.strout("  index_of('hello', 'll') = ");
    if (crz.index_of("hello", "ll")) |idx| {
        crz.logn(idx);
    }

    // =========================================================================
    // Mathematical Functions
    // =========================================================================
    crz.log("\n--- Mathematical Functions ---\n");

    // Trigonometry
    crz.log("Trigonometry:");
    crz.strout("  tan_f64(pi/4) = ");
    crz.logn(crz.tan_f64(std.math.pi / 4.0));

    // Min/Max/Clamp
    crz.log("\nMin/Max/Clamp:");
    crz.strout("  min(10, 5) = ");
    crz.logn(crz.min(@as(i32, 10), @as(i32, 5)));
    crz.strout("  max(10, 5) = ");
    crz.logn(crz.max(@as(i32, 10), @as(i32, 5)));
    crz.strout("  clamp(15, 0, 10) = ");
    crz.logn(crz.clamp(@as(i32, 15), 0, 10));

    // Factorial, GCD, LCM
    crz.log("\nNumber theory:");
    crz.strout("  factorial(5) = ");
    crz.logn(crz.factorial(5));
    crz.strout("  gcd(48, 18) = ");
    crz.logn(crz.gcd(@as(i32, 48), @as(i32, 18)));
    crz.strout("  lcm(4, 6) = ");
    crz.logn(crz.lcm(@as(i32, 4), @as(i32, 6)));

    // Primality
    crz.log("\nPrimality testing:");
    crz.strout("  is_prime(17) = ");
    crz.logn(crz.is_prime(17));
    crz.strout("  is_prime(18) = ");
    crz.logn(crz.is_prime(18));

    // Angle conversion
    crz.log("\nAngle conversion:");
    crz.strout("  deg_to_rad(180) = ");
    crz.logn(crz.deg_to_rad(@as(f64, 180.0)));
    crz.strout("  rad_to_deg(pi) = ");
    crz.logn(crz.rad_to_deg(@as(f64, std.math.pi)));

    // Interpolation
    crz.log("\nInterpolation:");
    crz.strout("  lerp(0, 100, 0.5) = ");
    crz.logn(crz.lerp(@as(f64, 0.0), @as(f64, 100.0), @as(f64, 0.5)));
    crz.strout("  inv_lerp(0, 100, 25) = ");
    crz.logn(crz.inv_lerp(@as(f64, 0.0), @as(f64, 100.0), @as(f64, 25.0)));
    crz.strout("  map_range(5, 0, 10, 0, 100) = ");
    crz.logn(crz.map_range(@as(f64, 5.0), @as(f64, 0.0), @as(f64, 10.0), @as(f64, 0.0), @as(f64, 100.0)));

    // Sign
    crz.log("\nSign function:");
    crz.strout("  sign(-42) = ");
    crz.logn(crz.sign(@as(i32, -42)));
    crz.strout("  sign(42) = ");
    crz.logn(crz.sign(@as(i32, 42)));
    crz.strout("  sign(0) = ");
    crz.logn(crz.sign(@as(i32, 0)));

    // =========================================================================
    // Array/Slice Utilities
    // =========================================================================
    crz.log("\n--- Array/Slice Utilities ---\n");

    const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    crz.log("Array operations on [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:");
    crz.strout("  sum() = ");
    crz.logn(crz.sum(&numbers));
    crz.strout("  avg() = ");
    crz.logn(crz.avg(&numbers));
    crz.strout("  slice_min() = ");
    if (crz.slice_min(&numbers)) |m| crz.logn(m);
    crz.strout("  slice_max() = ");
    if (crz.slice_max(&numbers)) |m| crz.logn(m);

    // Reverse
    crz.log("\nReverse:");
    var arr_to_reverse = [_]i32{ 1, 2, 3, 4, 5 };
    crz.strout("  Before: ");
    for (arr_to_reverse) |n| {
        crz.strout(" ");
        crz.logn(n);
    }
    crz.reverse(&arr_to_reverse);
    crz.strout("  After:  ");
    for (arr_to_reverse) |n| {
        crz.strout(" ");
        crz.logn(n);
    }

    // Binary search
    crz.log("\nBinary search on sorted array [1, 3, 5, 7, 9, 11, 13]:");
    const sorted = [_]i32{ 1, 3, 5, 7, 9, 11, 13 };
    crz.strout("  binary_search(7) = ");
    if (crz.binary_search(&sorted, 7)) |idx| {
        crz.logn(idx);
    }
    crz.strout("  binary_search(4) = ");
    if (crz.binary_search(&sorted, 4)) |idx| {
        crz.logn(idx);
    } else {
        crz.log("null (not found)");
    }

    // =========================================================================
    // Random Number Generation
    // =========================================================================
    crz.log("\n--- Random Number Generation ---\n");

    crz.log("Random floats [0, 1):");
    crz.strout("  rng_f32() = ");
    crz.logn(crz.rng_f32());
    crz.strout("  rng_f64() = ");
    crz.logn(crz.rng_f64());

    crz.log("\nRandom floats in range [5, 10):");
    crz.strout("  rng_f32_range(5, 10) = ");
    crz.logn(crz.rng_f32_range(5.0, 10.0));
    crz.strout("  rng_f64_range(5, 10) = ");
    crz.logn(crz.rng_f64_range(5.0, 10.0));

    crz.log("\nRandom boolean:");
    crz.strout("  rng_bool() = ");
    crz.logn(crz.rng_bool());

    // Shuffle
    crz.log("\nShuffle:");
    var to_shuffle = [_]i32{ 1, 2, 3, 4, 5 };
    crz.strout("  Before: ");
    for (to_shuffle) |n| {
        crz.strout(" ");
        crz.logn(n);
    }
    crz.shuffle(&to_shuffle);
    crz.strout("  After:  ");
    for (to_shuffle) |n| {
        crz.strout(" ");
        crz.logn(n);
    }

    // Random choice
    crz.log("\nRandom choice from [10, 20, 30, 40, 50]:");
    const choices = [_]i32{ 10, 20, 30, 40, 50 };
    crz.strout("  rng_choice() = ");
    if (crz.rng_choice(&choices)) |c| crz.logn(c);

    // =========================================================================
    // Bit Manipulation
    // =========================================================================
    crz.log("\n--- Bit Manipulation ---\n");

    crz.log("Bit operations:");
    crz.strout("  popcount(0b10110101) = ");
    crz.logn(crz.popcount(@as(u8, 0b10110101)));
    crz.strout("  leading_zeros(0b00001000) = ");
    crz.logn(crz.leading_zeros(@as(u8, 0b00001000)));
    crz.strout("  trailing_zeros(0b00001000) = ");
    crz.logn(crz.trailing_zeros(@as(u8, 0b00001000)));

    crz.log("\nPower of two operations:");
    crz.strout("  is_power_of_two(8) = ");
    crz.logn(crz.is_power_of_two(@as(u32, 8)));
    crz.strout("  is_power_of_two(6) = ");
    crz.logn(crz.is_power_of_two(@as(u32, 6)));
    crz.strout("  next_power_of_two(5) = ");
    crz.logn(crz.next_power_of_two(@as(u32, 5)));
    crz.strout("  next_power_of_two(8) = ");
    crz.logn(crz.next_power_of_two(@as(u32, 8)));

    // =========================================================================
    // File Operations
    // =========================================================================
    crz.log("\n--- File Operations ---\n");

    const test_file = "example_test.txt";
    crz.log("Writing to file...");
    try crz.write_file(test_file, "Hello from CRZLib!\n");
    crz.strout("  file_size('");
    crz.strout(test_file);
    crz.strout("') = ");
    const size = try crz.file_size(test_file);
    crz.logn(size);

    crz.log("Appending to file...");
    try crz.append_file(test_file, "Second line!\n");
    crz.strout("  file_size after append = ");
    const new_size = try crz.file_size(test_file);
    crz.logn(new_size);

    crz.strout("  exists('");
    crz.strout(test_file);
    crz.strout("') = ");
    crz.logn(crz.exists(test_file));

    // Cleanup
    try std.fs.cwd().deleteFile(test_file);

    crz.log("\n=== All examples completed successfully! ===");
}
