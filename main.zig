const crz = @import("crzlib.zig");
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("\nCRZLib Test Suite\n", .{});
    print("================\n", .{});

    // Test Error Reporting
    test_error_reporting();

    // Test Command Line Arguments
    test_command_line_args();

    // Test File Operations
    test_file_operations();

    // Test System Commands
    test_system_commands();

    // Test String Operations
    test_string_operations();

    // Test Random Number Generation
    test_random_numbers();

    // Test Mathematical Functions
    test_math_functions();

    // Test Console I/O
    test_console_io();

    // Test Number Parsing
    test_number_parsing();

    // Test Square Root and Inverse Square Root Performance
    test_sqrt_performance();

    print("\nAll tests completed!\n", .{});
}

fn test_error_reporting() void {
    print("\nTesting Error Reporting:\n", .{});
    print("------------------------\n", .{});
    crz.liberr("Test error message");
    crz.liberr("Another test error");
}

fn test_command_line_args() void {
    print("\nTesting Command Line Arguments:\n", .{});
    print("-----------------------------\n", .{});
    const allocator = std.heap.page_allocator;
    const args = crz.get_args(allocator) catch {
        print("Failed to get command line arguments\n", .{});
        return;
    };
    defer allocator.free(args);

    print("Command line arguments:\n", .{});
    for (args) |arg| {
        print("  {s}\n", .{arg});
    }
}

fn test_file_operations() void {
    print("\nTesting File Operations:\n", .{});
    print("----------------------\n", .{});

    // Test is_file
    print("Testing is_file:\n", .{});
    print("  main.zig exists: {}\n", .{crz.is_file("main.zig")});
    print("  nonexistent.txt exists: {}\n", .{crz.is_file("nonexistent.txt")});

    // Test is_dir
    print("\nTesting is_dir:\n", .{});
    print("  Current directory is valid: {}\n", .{crz.is_dir(".")});
    print("  Nonexistent directory is valid: {}\n", .{crz.is_dir("nonexistent_dir")});

    // Test read_file
    print("\nTesting read_file:\n", .{});
    const allocator = std.heap.page_allocator;
    const lines = crz.read_file(allocator, "main.zig") catch {
        print("Failed to read main.zig\n", .{});
        return;
    };
    defer allocator.free(lines);

    print("First few lines of main.zig:\n", .{});
    for (lines[0..@min(3, lines.len)]) |line| {
        print("  {s}\n", .{line});
    }
}

fn test_system_commands() void {
    print("\nTesting System Commands:\n", .{});
    print("----------------------\n", .{});

    // Test c_system
    print("Testing c_system:\n", .{});
    crz.c_system("dir");

    // Test term
    print("\nTesting term:\n", .{});
    crz.term(&[_][]const u8{ "echo", "Hello from term!" }) catch {
        print("Term command failed\n", .{});
    };

    // Test open_url (Windows only)
    print("\nTesting open_url:\n", .{});
    crz.open_url("https://github.com");

    // Test open_file (Windows only)
    print("\nTesting open_file:\n", .{});
    crz.open_file("main.zig");
}

fn test_string_operations() void {
    print("\nTesting String Operations:\n", .{});
    print("------------------------\n", .{});

    // Test streql
    print("Testing streql:\n", .{});
    print("  'hello' == 'hello': {}\n", .{crz.streql("hello", "hello")});
    print("  'hello' == 'world': {}\n", .{crz.streql("hello", "world")});

    // Test strcat
    print("\nTesting strcat:\n", .{});
    const allocator = std.heap.page_allocator;
    const result = crz.strcat(allocator, "Hello, ", "World!") catch {
        print("String concatenation failed\n", .{});
        return;
    };
    defer allocator.free(result);
    print("  Concatenated: {s}\n", .{result});

    // Test strsplit
    print("\nTesting strsplit:\n", .{});
    const split = crz.strsplit("foo:bar:baz", ":") catch {
        print("String splitting failed\n", .{});
        return;
    };
    defer allocator.free(split);
    print("  Split result:\n", .{});
    for (split) |s| {
        print("    {s}\n", .{s});
    }
}

fn test_random_numbers() void {
    print("\nTesting Random Number Generation:\n", .{});
    print("--------------------------------\n", .{});

    // Test rng_i32
    print("Testing rng_i32:\n", .{});
    for (0..5) |_| {
        print("  {d} ", .{crz.rng_i32(1, 100)});
    }
    print("\n", .{});

    // Test rng_i64
    print("\nTesting rng_i64:\n", .{});
    for (0..5) |_| {
        print("  {d} ", .{crz.rng_i64(1, 100)});
    }
    print("\n", .{});

    // Test rng_i128
    print("\nTesting rng_i128:\n", .{});
    for (0..5) |_| {
        print("  {d} ", .{crz.rng_i128(1, 100)});
    }
    print("\n", .{});

    // Test rng_usize
    print("\nTesting rng_usize:\n", .{});
    for (0..5) |_| {
        print("  {d} ", .{crz.rng_usize(1, 100)});
    }
    print("\n", .{});
}

fn test_math_functions() void {
    print("\nTesting Mathematical Functions:\n", .{});
    print("-----------------------------\n", .{});

    // Test sqrt_f64 with various inputs
    print("Testing sqrt_f64:\n", .{});
    const test_cases = [_]f64{ 0.0, 1.0, 2.0, 4.0, 16.0, 25.0, 100.0, 1000.0, 1e6, 1e-6, -1.0 };
    for (test_cases) |n| {
        const result = crz.sqrt_f64(n);
        print("  sqrt({d}) = {d}\n", .{ n, result });
    }

    // Test sqrt_f64 with irrational numbers
    print("\nTesting sqrt_f64 with irrational numbers:\n", .{});
    const irrational_cases = [_]f64{ 2.0, 3.0, 5.0, 7.0, 10.0 };
    for (irrational_cases) |n| {
        const result = crz.sqrt_f64(n);
        print("  sqrt({d}) = {d}\n", .{ n, result });
    }

    // Test sqrt_f64 with very small numbers
    print("\nTesting sqrt_f64 with very small numbers:\n", .{});
    const small_cases = [_]f64{ 1e-10, 1e-20, 1e-30 };
    for (small_cases) |n| {
        const result = crz.sqrt_f64(n);
        print("  sqrt({d}) = {d}\n", .{ n, result });
    }

    // Test sqrt_f64 with very large numbers
    print("\nTesting sqrt_f64 with very large numbers:\n", .{});
    const large_cases = [_]f64{ 1e10, 1e20, 1e30 };
    for (large_cases) |n| {
        const result = crz.sqrt_f64(n);
        print("  sqrt({d}) = {d}\n", .{ n, result });
    }

    // Test inv_sqrt
    print("\nTesting inv_sqrt:\n", .{});
    print("  inv_sqrt(16) = {d}\n", .{crz.inv_sqrt_f64(16.0)});
    print("  inv_sqrt(2) = {d}\n", .{crz.inv_sqrt_f64(2.0)});

    // Test pow
    print("\nTesting pow:\n", .{});
    print("  2^3 = {d}\n", .{crz.pow(2, 3)});
    print("  5^2 = {d}\n", .{crz.pow(5, 2)});
    print("  10^0 = {d}\n", .{crz.pow(10, 0)});
}

fn test_console_io() void {
    print("\nTesting Console I/O:\n", .{});
    print("------------------\n", .{});

    // Test strout
    print("Testing strout:\n", .{});
    crz.strout("This is a test ");
    crz.strout("without newline\n");

    // Test log
    print("\nTesting log:\n", .{});
    crz.log("This is a test with newline");
    crz.log("Another test line");

    // Test cin
    print("\nTesting cin (please enter some text):\n", .{});
    var buf: [100]u8 = undefined;
    const input = crz.cin(&buf, "Enter text: ") catch {
        print("Failed to read input\n", .{});
        return;
    };
    print("You entered: {s}\n", .{input});
}

fn test_number_parsing() void {
    print("\nTesting Number Parsing:\n", .{});
    print("----------------------\n", .{});

    // Test integer parsing
    print("Testing integer parsing:\n", .{});
    print("  str_i8('123') = {d}\n", .{crz.str_i8("123")});
    print("  str_i16('1234') = {d}\n", .{crz.str_i16("1234")});
    print("  str_i32('12345') = {d}\n", .{crz.str_i32("12345")});
    print("  str_i64('123456') = {d}\n", .{crz.str_i64("123456")});
    print("  str_i128('1234567') = {d}\n", .{crz.str_i128("1234567")});

    // Test float parsing
    print("\nTesting float parsing:\n", .{});
    print("  str_f32('3.14') = {d}\n", .{crz.str_f32("3.14")});
    print("  str_f64('3.14159') = {d}\n", .{crz.str_f64("3.14159")});
    print("  str_f128('3.14159265359') = {d}\n", .{crz.str_f128("3.14159265359")});

    // Test invalid input
    print("\nTesting invalid input:\n", .{});
    print("  str_i32('abc') = {d}\n", .{crz.str_i32("abc")});
    print("  str_f64('xyz') = {d}\n", .{crz.str_f64("xyz")});
}

fn test_sqrt_performance() void {
    print("\nTesting Square Root and Inverse Square Root Performance:\n", .{});
    print("----------------------------------------------------\n", .{});

    const iterations = 1_000_000;
    const warmup = 100_000;
    const test_cases_f32 = [_]f32{ 1.0, 2.0, 4.0, 16.0, 100.0, 1000.0, 1e6, 1e-6 };
    const test_cases_f64 = [_]f64{ 1.0, 2.0, 4.0, 16.0, 100.0, 1000.0, 1e6, 1e-6 };
    const test_cases_f128 = [_]f128{ 1.0, 2.0, 4.0, 16.0, 100.0, 1000.0, 1e6, 1e-6 };

    // Warmup phase
    print("Warming up...\n", .{});
    for (0..warmup) |_| {
        for (test_cases_f32) |n| {
            _ = crz.sqrt_f32(n);
            _ = crz.inv_sqrt_f32(n);
            _ = crz.sqrt_f64(@as(f64, n));
            _ = crz.inv_sqrt_f64(@as(f64, n));
            _ = crz.sqrt_f128(@as(f128, n));
            _ = crz.inv_sqrt_f128(@as(f128, n));
        }
        for (test_cases_f64) |n| {
            _ = crz.sqrt_f32(@as(f32, @floatCast(n)));
            _ = crz.inv_sqrt_f32(@as(f32, @floatCast(n)));
            _ = crz.sqrt_f64(n);
            _ = crz.inv_sqrt_f64(n);
            _ = crz.sqrt_f128(@as(f128, n));
            _ = crz.inv_sqrt_f128(@as(f128, n));
        }
        for (test_cases_f128) |n| {
            _ = crz.sqrt_f32(@as(f32, @floatCast(n)));
            _ = crz.inv_sqrt_f32(@as(f32, @floatCast(n)));
            _ = crz.sqrt_f64(@as(f64, @floatCast(n)));
            _ = crz.inv_sqrt_f64(@as(f64, @floatCast(n)));
            _ = crz.sqrt_f128(n);
            _ = crz.inv_sqrt_f128(n);
        }
    }

    // Test sqrt_f32
    print("\nTesting sqrt_f32:\n", .{});
    const start_sqrt_f32 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f32) |n| {
            _ = crz.sqrt_f32(n);
        }
    }
    const end_sqrt_f32 = std.time.nanoTimestamp();
    const sqrt_f32_time = @as(f64, @floatFromInt(end_sqrt_f32 - start_sqrt_f32)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{sqrt_f32_time});
    print("  Average time per call: {d:.3}ns\n", .{sqrt_f32_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f32.len))});

    // Test inv_sqrt_f32
    print("\nTesting inv_sqrt_f32:\n", .{});
    const start_inv_f32 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f32) |n| {
            _ = crz.inv_sqrt_f32(n);
        }
    }
    const end_inv_f32 = std.time.nanoTimestamp();
    const inv_f32_time = @as(f64, @floatFromInt(end_inv_f32 - start_inv_f32)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{inv_f32_time});
    print("  Average time per call: {d:.3}ns\n", .{inv_f32_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f32.len))});

    // Test sqrt_f64
    print("\nTesting sqrt_f64:\n", .{});
    const start_sqrt_f64 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f64) |n| {
            _ = crz.sqrt_f64(n);
        }
    }
    const end_sqrt_f64 = std.time.nanoTimestamp();
    const sqrt_f64_time = @as(f64, @floatFromInt(end_sqrt_f64 - start_sqrt_f64)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{sqrt_f64_time});
    print("  Average time per call: {d:.3}ns\n", .{sqrt_f64_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f64.len))});

    // Test inv_sqrt_f64
    print("\nTesting inv_sqrt_f64:\n", .{});
    const start_inv_f64 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f64) |n| {
            _ = crz.inv_sqrt_f64(n);
        }
    }
    const end_inv_f64 = std.time.nanoTimestamp();
    const inv_f64_time = @as(f64, @floatFromInt(end_inv_f64 - start_inv_f64)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{inv_f64_time});
    print("  Average time per call: {d:.3}ns\n", .{inv_f64_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f64.len))});

    // Test sqrt_f128
    print("\nTesting sqrt_f128:\n", .{});
    const start_sqrt_f128 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f128) |n| {
            _ = crz.sqrt_f128(n);
        }
    }
    const end_sqrt_f128 = std.time.nanoTimestamp();
    const sqrt_f128_time = @as(f64, @floatFromInt(end_sqrt_f128 - start_sqrt_f128)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{sqrt_f128_time});
    print("  Average time per call: {d:.3}ns\n", .{sqrt_f128_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f128.len))});

    // Test inv_sqrt_f128
    print("\nTesting inv_sqrt_f128:\n", .{});
    const start_inv_f128 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_cases_f128) |n| {
            _ = crz.inv_sqrt_f128(n);
        }
    }
    const end_inv_f128 = std.time.nanoTimestamp();
    const inv_f128_time = @as(f64, @floatFromInt(end_inv_f128 - start_inv_f128)) / 1_000_000.0;
    print("  Time: {d:.2}ms\n", .{inv_f128_time});
    print("  Average time per call: {d:.3}ns\n", .{inv_f128_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f128.len))});

    // Compare results
    print("\nPerformance Comparison:\n", .{});
    print("  sqrt_f32:    {d:.2}ms ({d:.3}ns/call)\n", .{ sqrt_f32_time, sqrt_f32_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f32.len)) });
    print("  inv_sqrt_f32: {d:.2}ms ({d:.3}ns/call)\n", .{ inv_f32_time, inv_f32_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f32.len)) });
    print("  sqrt_f64:    {d:.2}ms ({d:.3}ns/call)\n", .{ sqrt_f64_time, sqrt_f64_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f64.len)) });
    print("  inv_sqrt_f64: {d:.2}ms ({d:.3}ns/call)\n", .{ inv_f64_time, inv_f64_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f64.len)) });
    print("  sqrt_f128:   {d:.2}ms ({d:.3}ns/call)\n", .{ sqrt_f128_time, sqrt_f128_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f128.len)) });
    print("  inv_sqrt_f128: {d:.2}ms ({d:.3}ns/call)\n", .{ inv_f128_time, inv_f128_time * 1_000_000 / @as(f64, @floatFromInt(iterations * test_cases_f128.len)) });

    print("\nRelative Performance:\n", .{});
    print("  sqrt_f32 vs inv_sqrt_f32: {d:.2}x\n", .{sqrt_f32_time / inv_f32_time});
    print("  sqrt_f64 vs inv_sqrt_f64: {d:.2}x\n", .{sqrt_f64_time / inv_f64_time});
    print("  sqrt_f128 vs inv_sqrt_f128: {d:.2}x\n", .{sqrt_f128_time / inv_f128_time});
    print("  inv_sqrt_f32 vs sqrt_f32: {d:.2}x\n", .{inv_f32_time / sqrt_f32_time});
    print("  inv_sqrt_f64 vs sqrt_f64: {d:.2}x\n", .{inv_f64_time / sqrt_f64_time});
    print("  inv_sqrt_f128 vs sqrt_f128: {d:.2}x\n", .{inv_f128_time / sqrt_f128_time});

    // Find fastest
    const times = [_]f64{ sqrt_f32_time, inv_f32_time, sqrt_f64_time, inv_f64_time, sqrt_f128_time, inv_f128_time };
    const names = [_][]const u8{ "sqrt_f32", "inv_sqrt_f32", "sqrt_f64", "inv_sqrt_f64", "sqrt_f128", "inv_sqrt_f128" };
    var fastest_idx: usize = 0;
    var fastest_time = times[0];
    for (times, 0..) |time, i| {
        if (time < fastest_time) {
            fastest_time = time;
            fastest_idx = i;
        }
    }
    print("\nFastest Implementation: {s}\n", .{names[fastest_idx]});
}
