// MIT License
//
// Copyright (c) 2024 CJ Remillard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// CRZLib - A Utility Library for Zig
/// Author: CJ Remillard
/// Updated for Zig 0.15
///
/// This library provides a collection of utility functions for common programming tasks
/// including file operations, string manipulation, mathematical functions, and more.
///
/// Key Features:
/// - File and Directory Operations
/// - String Manipulation
/// - Random Number Generation
/// - Mathematical Functions
/// - System Commands
/// - Number Parsing
/// - Console I/O
pub const std = @import("std");
pub const print = std.debug.print;
pub const str = []const u8;
pub const random = std.crypto.random;

//=============================================================================
// External Dependencies
//=============================================================================
pub const cstdlib = @cImport(@cInclude("stdlib.h"));

//=============================================================================
// Error Handling
//=============================================================================
/// Error Reporting
/// Prints formatted error messages with the CRZLib prefix
/// Example: liberr("File not found");
pub fn liberr(report: str) void {
    strout("\n@CRZLib(**ERROR**) >> ");
    strout(report);
}

//=============================================================================
// System Operations
//=============================================================================
/// Command Line Arguments
/// Returns an array of command line arguments (excluding program name)
/// Memory must be freed by the caller using allocator.free()
/// Example: const args = try get_args(allocator);
pub fn get_args(allocator: std.mem.Allocator) ![][]const u8 {
    // Get all command line arguments
    var arg_it = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, arg_it);

    // Create a dynamic array to store arguments
    var args = std.array_list.Managed([]const u8).init(allocator);
    defer args.deinit();

    // Skip program name and copy remaining arguments
    for (arg_it[1..]) |arg| {
        const arg_copy = try allocator.dupe(u8, arg);
        try args.append(arg_copy);
    }

    return args.toOwnedSlice();
}

/// System Commands
/// Executes a system command using the C standard library
/// Example: c_system("dir");
pub fn c_system(s: [*c]const u8) void {
    _ = cstdlib.system(s);
}

//=============================================================================
// File System Operations
//=============================================================================
/// File Operations
/// Reads a file and returns its contents as an array of strings (one per line)
/// Memory must be freed by the caller using allocator.free()
/// Example: const lines = try read_file(allocator, "input.txt");
pub fn read_file(allocator: std.mem.Allocator, path: []const u8) ![][]const u8 {
    // Open the file for reading
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    // Create a dynamic array to store lines
    var lines = std.array_list.Managed([]const u8).init(allocator);
    defer lines.deinit();

    // Set up buffered reading - FIXED for Zig 0.15
    var read_buf: [4096]u8 = undefined;
    var file_reader = file.reader(&read_buf);
    const reader = &file_reader.interface;

    // Read file line by line using the new API
    while (reader.takeDelimiterExclusive('\n')) |line| {
        const line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
    } else |err| switch (err) {
        error.EndOfStream => {}, // Normal end of file
        else => return err,
    }

    return lines.toOwnedSlice();
}

/// File System Checks
/// Returns true if the path points to a file
/// Example: if (is_file("test.txt")) { ... }
pub fn is_file(path: []const u8) bool {
    // Try to get file stats, return false if not a file
    const stat = std.fs.cwd().statFile(path) catch |err| switch (err) {
        error.FileNotFound => return false,
        error.IsDir => return false,
        else => return false,
    };
    _ = stat;
    return true;
}

/// Directory Checks
/// Returns true if the path points to a directory
/// Example: if (is_dir("folder")) { ... }
pub fn is_dir(path: []const u8) bool {
    // Try to open as directory, return false if not a directory
    var dir = std.fs.cwd().openDir(path, .{}) catch return false;
    defer dir.close();
    return true;
}

//=============================================================================
// Terminal and OS Operations
//=============================================================================
/// Terminal Commands
/// Executes a command in the terminal and returns its output
/// Example: try term(&[_][]const u8{"dir"});
pub fn term(argv: []const []const u8) !void {
    // Set up arena allocator for command execution
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Execute command and print output
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });

    std.debug.print("{s}\n", .{result.stdout});
}

/// OS-Specific Functions
/// Opens a URL in the default browser (Windows only)
/// Example: open_url("https://example.com");
pub fn open_url(url: []const u8) void {
    term(&[_][]const u8{ "explorer", url }) catch liberr("Failed to open URL!\n");
}

/// Opens a file with the default application (Windows only)
/// Example: open_file("document.pdf");
pub fn open_file(file_path: []const u8) void {
    term(&[_][]const u8{ "explorer", file_path }) catch liberr("Failed to open file!\n");
}

//=============================================================================
// String Operations
//=============================================================================
/// String Operations
/// Compares two strings for equality
/// Example: if (streql("hello", "hello")) { ... }
pub fn streql(s1: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s1, s2);
}

/// Concatenates two strings
/// Memory must be freed by the caller using allocator.free()
/// Example: const result = try strcat(allocator, "Hello ", "World");
pub fn strcat(allocator: std.mem.Allocator, s1: []const u8, s2: []const u8) ![]const u8 {
    return std.mem.concat(allocator, u8, &[_][]const u8{ s1, s2 });
}

/// Splits a string based on a pattern
/// Memory must be freed by the caller using allocator.free()
/// Example: const parts = try strsplit("a,b,c", ",");
pub fn strsplit(input: []const u8, pattern: []const u8) ![][]const u8 {
    const allocator = std.heap.page_allocator;
    var results = std.array_list.Managed([]const u8).init(allocator);
    errdefer results.deinit();

    // Handle empty pattern case
    if (pattern.len == 0) {
        const copy = try allocator.dupe(u8, input);
        try results.append(copy);
        return results.toOwnedSlice();
    }

    // Split string based on pattern
    var start: usize = 0;
    while (std.mem.indexOf(u8, input[start..], pattern)) |pos| {
        if (pos > 0) {
            const substring = try allocator.dupe(u8, input[start .. start + pos]);
            try results.append(substring);
        }
        start += pos + pattern.len;
    }

    // Add remaining part of string
    if (start < input.len) {
        const substring = try allocator.dupe(u8, input[start..]);
        try results.append(substring);
    }

    return results.toOwnedSlice();
}

//=============================================================================
// Random Number Generation
//=============================================================================
/// Random Number Generation
/// Generates random integers in the specified range
/// Example: const num = rng_i32(1, 100);
pub fn rng_i32(min_val: i32, max_val: i32) i32 {
    if (max_val - min_val > 0) {
        return random.intRangeAtMost(i32, min_val, max_val);
    } else {
        return min_val;
    }
}

/// Generates random 64-bit integers in the specified range
/// Example: const num = rng_i64(1, 1000);
pub fn rng_i64(min_val: i64, max_val: i64) i64 {
    if (max_val - min_val > 0) {
        return random.intRangeAtMost(i64, min_val, max_val);
    } else {
        return min_val;
    }
}

/// Generates random 128-bit integers in the specified range
/// Example: const num = rng_i128(1, 10000);
pub fn rng_i128(min_val: i128, max_val: i128) i128 {
    if (max_val - min_val > 0) {
        return random.intRangeAtMost(i128, min_val, max_val);
    } else {
        return min_val;
    }
}

/// Generates random usize values in the specified range
/// Example: const num = rng_usize(0, 100);
pub fn rng_usize(min_val: usize, max_val: usize) usize {
    if (max_val - min_val > 0) {
        return random.intRangeAtMost(usize, min_val, max_val);
    } else {
        return min_val;
    }
}

//=============================================================================
// Mathematical Functions
//=============================================================================
/// Square root functions using Newton-Raphson method
/// Calculates square root of a 32-bit float
/// Example: const root = sqrt_f32(16.0);
pub fn sqrt_f32(n: f32) f32 {
    // Handle special cases
    if (n < 0) return -1;
    if (n == 0) return 0;
    if (n == 1) return 1;

    // Initial guess
    var guess = n * 0.5;
    var prev_guess: f32 = 0;
    const tolerance = 1e-6;

    // Newton-Raphson iteration
    while (@abs(guess - prev_guess) > tolerance) {
        prev_guess = guess;
        guess = (guess + n / guess) * 0.5;
    }

    return guess;
}

/// Calculates square root of a 64-bit float
/// Example: const root = sqrt_f64(16.0);
pub fn sqrt_f64(n: f64) f64 {
    // Handle special cases
    if (n < 0) return -1;
    if (n == 0) return 0;
    if (n == 1) return 1;

    // Initial guess
    var guess = n * 0.5;
    var prev_guess: f64 = 0;
    const tolerance = 1e-10;

    // Newton-Raphson iteration
    while (@abs(guess - prev_guess) > tolerance) {
        prev_guess = guess;
        guess = (guess + n / guess) * 0.5;
    }

    return guess;
}

/// Calculates square root of a 128-bit float
/// Example: const root = sqrt_f128(16.0);
pub fn sqrt_f128(n: f128) f128 {
    // Handle special cases
    if (n < 0) return -1;
    if (n == 0) return 0;
    if (n == 1) return 1;

    // Initial guess
    var guess = n * 0.5;
    var prev_guess: f128 = 0;
    const tolerance = 1e-30;

    // Newton-Raphson iteration
    while (@abs(guess - prev_guess) > tolerance) {
        prev_guess = guess;
        guess = (guess + n / guess) * 0.5;
    }

    return guess;
}

/// Helper function for absolute value
/// Returns the absolute value of a 64-bit float
/// Example: const abs = abs_f64(-42.0);
pub fn abs_f64(n: f64) f64 {
    if (n < 0) return -n;
    return n;
}

/// Inverse square root functions using fast inverse square root algorithm
/// Calculates inverse square root of a 32-bit float
/// Example: const inv = inv_sqrt_f32(16.0);
pub fn inv_sqrt_f32(x: f32) f32 {
    // Handle special cases
    if (x < 0.0) return 0.0;
    if (x == 0.0) return 0.0;
    if (x == 1.0) return 1.0;

    // Fast inverse square root algorithm
    const half = 0.5 * x;
    var i: u32 = @bitCast(x);
    i = 0x5f3759df - (i >> 1);
    var y: f32 = @bitCast(i);
    y = y * (1.5 - (half * y * y)); // One Newton-Raphson iteration
    return y;
}

/// Calculates inverse square root of a 64-bit float
/// Example: const inv = inv_sqrt_f64(16.0);
pub fn inv_sqrt_f64(n: f64) f64 {
    // Handle special cases
    if (n <= 0) return 0;
    if (n == 1) return 1;

    // Fast inverse square root algorithm
    const x2 = n * 0.5;
    const threehalfs = 1.5;
    var i = @as(i64, @bitCast(n));
    i = 0x5fe6eb50c7b537a9 - (i >> 1);
    var y = @as(f64, @bitCast(i));
    y = y * (threehalfs - (x2 * y * y));
    y = y * (threehalfs - (x2 * y * y));

    return y;
}

/// Calculates inverse square root of a 128-bit float
/// Example: const inv = inv_sqrt_f128(16.0);
pub fn inv_sqrt_f128(n: f128) f128 {
    // Handle special cases
    if (n <= 0) return 0;
    if (n == 1) return 1;

    // Fast inverse square root algorithm
    const x2 = n * 0.5;
    const threehalfs = 1.5;
    var i = @as(i128, @bitCast(n));
    i = 0x5fe6eb50c7b537a9 - (i >> 1);
    var y = @as(f128, @bitCast(i));
    y = y * (threehalfs - (x2 * y * y));
    y = y * (threehalfs - (x2 * y * y));
    y = y * (threehalfs - (x2 * y * y));

    return y;
}

// Computes the sine of a floating-point number (x) using the Maclaurin series expansion.
// sin(x) ≈ x - x^3/3! + x^5/5! - x^7/7! + ... (up to n terms)
pub fn sin_f32(x: f32) f32 {
    // Number of terms in the series expansion, affecting precision
    const n = 15;

    // The first term in the Maclaurin series is x itself
    var t: f32 = x;
    var sin: f32 = t; // Initialize result with the first term
    var a: f32 = 1; // Factorial tracking variable (starting at 1)

    // Loop to compute the subsequent terms in the series
    for (0..n) |_| {
        // Compute the next term: (-x^2) / ((2a) * (2a + 1))
        // This represents the factorial denominator and sign alternation
        const mul = -x * x / ((2 * a) * (2 * a + 1));

        // Multiply the previous term by mul to get the next term
        t *= mul;

        // Add the computed term to the sine sum
        sin += t;

        // Increment a for the next factorial calculation
        a += 1;
    }

    // Return the approximated sine value
    return sin;
}

// Computes the cosine of a floating-point number (x) using the Maclaurin series expansion.
// cos(x) ≈ 1 - x^2/2! + x^4/4! - x^6/6! + ... (up to n terms)
pub fn cos_f32(x: f32) f32 {
    // Number of terms in the series expansion, affecting precision
    const n = 15;

    // The first term in the Maclaurin series is 1
    var t: f32 = 1;
    var cos: f32 = t; // Initialize result with the first term
    var a: f32 = 1; // Factorial tracking variable (starting at 1)

    // Loop to compute the subsequent terms in the series
    for (0..n) |_| {
        // Compute the next term: (-x^2) / ((2a) * (2a - 1))
        // This represents the factorial denominator and sign alternation
        const mul = -x * x / ((2 * a) * (2 * a - 1));

        // Multiply the previous term by mul to get the next term
        t *= mul;

        // Add the computed term to the cosine sum
        cos += t;

        // Increment a for the next factorial calculation
        a += 1;
    }

    // Return the approximated cosine value
    return cos;
}

// Computes the sine of a floating-point number (x) using the Maclaurin series expansion.
// sin(x) ≈ x - x^3/3! + x^5/5! - x^7/7! + ... (up to n terms)
pub fn sin_f64(x: f64) f64 {
    // Number of terms in the series expansion, affecting precision
    const n = 15;

    // The first term in the Maclaurin series is x itself
    var t: f64 = x;
    var sin: f64 = t; // Initialize result with the first term
    var a: f64 = 1; // Factorial tracking variable (starting at 1)

    // Loop to compute the subsequent terms in the series
    for (0..n) |_| {
        // Compute the next term: (-x^2) / ((2a) * (2a + 1))
        // This represents the factorial denominator and sign alternation
        const mul = -x * x / ((2 * a) * (2 * a + 1));

        // Multiply the previous term by mul to get the next term
        t *= mul;

        // Add the computed term to the sine sum
        sin += t;

        // Increment a for the next factorial calculation
        a += 1;
    }

    // Return the approximated sine value
    return sin;
}

// Computes the cosine of a floating-point number (x) using the Maclaurin series expansion.
// cos(x) ≈ 1 - x^2/2! + x^4/4! - x^6/6! + ... (up to n terms)
pub fn cos_f64(x: f64) f64 {
    // Number of terms in the series expansion, affecting precision
    const n = 15;

    // The first term in the Maclaurin series is 1
    var t: f64 = 1;
    var cos: f64 = t; // Initialize result with the first term
    var a: f64 = 1; // Factorial tracking variable (starting at 1)

    // Loop to compute the subsequent terms in the series
    for (0..n) |_| {
        // Compute the next term: (-x^2) / ((2a) * (2a - 1))
        // This represents the factorial denominator and sign alternation
        const mul = -x * x / ((2 * a) * (2 * a - 1));

        // Multiply the previous term by mul to get the next term
        t *= mul;

        // Add the computed term to the cosine sum
        cos += t;

        // Increment a for the next factorial calculation
        a += 1;
    }

    // Return the approximated cosine value
    return cos;
}

/// Power function
/// Calculates x raised to the power of exp
/// Example: const result = pow(2, 3); // returns 8
pub fn pow(x: anytype, exp: usize) @TypeOf(x) {
    if (exp == 0) {
        return @as(@TypeOf(x), 1);
    }

    var y = x;
    for (0..exp - 1) |_| {
        y *= x;
    }

    return y;
}

//=============================================================================
// Console I/O Operations
//=============================================================================
/// Console Output
/// Prints a string without a newline
/// Example: strout("Hello ");
pub fn strout(s: []const u8) void {
    print("{s}", .{s});
}

/// Prints a string with a newline
/// Example: log("Hello World");
pub fn log(s: []const u8) void {
    print("{s}\n", .{s});
}
//
pub fn logn(x: anytype) void {
    print("{}\n", .{x});
}

/// Console Input
/// Reads a line from stdin with a prompt
/// Example: var buf: [256]u8 = undefined;
///          const input = try cin(&buf, "Enter text: ");
pub fn cin(buf: []u8, prompt: []const u8) ![]const u8 {
    _ = buf; // Buffer is managed internally now
    var read_buf: [4096]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&read_buf);
    const reader = &stdin_reader.interface;
    
    // Print prompt
    var write_buf: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&write_buf);
    const stdout = &stdout_writer.interface;
    try stdout.writeAll(prompt);
    try stdout.flush();
    
    // Read line
    const line = reader.takeDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream => return "",
        else => return err,
    };
    
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trim(u8, line, "\r");
    } else {
        return line;
    }
}

//=============================================================================
// Number Parsing
//=============================================================================
/// String to Integer Conversion
/// Converts string to i8, returns 0 if parsing fails
/// Example: const num = str_i8("42");
pub fn str_i8(s: []const u8) i8 {
    return std.fmt.parseInt(i8, s, 10) catch 0;
}

/// Converts string to i16, returns 0 if parsing fails
/// Example: const num = str_i16("42");
pub fn str_i16(s: []const u8) i16 {
    return std.fmt.parseInt(i16, s, 10) catch 0;
}

/// Converts string to i32, returns 0 if parsing fails
/// Example: const num = str_i32("42");
pub fn str_i32(s: []const u8) i32 {
    return std.fmt.parseInt(i32, s, 10) catch 0;
}

/// Converts string to i64, returns 0 if parsing fails
/// Example: const num = str_i64("42");
pub fn str_i64(s: []const u8) i64 {
    return std.fmt.parseInt(i64, s, 10) catch 0;
}

/// Converts string to i128, returns 0 if parsing fails
/// Example: const num = str_i128("42");
pub fn str_i128(s: []const u8) i128 {
    return std.fmt.parseInt(i128, s, 10) catch 0;
}

/// String to Float Conversion
/// Converts string to f32, returns 0.0 if parsing fails
/// Example: const num = str_f32("42.5");
pub fn str_f32(s: []const u8) f32 {
    return std.fmt.parseFloat(f32, s) catch 0.0;
}

/// Converts string to f64, returns 0.0 if parsing fails
/// Example: const num = str_f64("42.5");
pub fn str_f64(s: []const u8) f64 {
    return std.fmt.parseFloat(f64, s) catch 0.0;
}

/// Converts string to f128, returns 0.0 if parsing fails
/// Example: const num = str_f128("42.5");
pub fn str_f128(s: []const u8) f128 {
    return std.fmt.parseFloat(f128, s) catch 0.0;
}

pub fn sleep_ms(ms: u64) void {
    std.Thread.sleep(ms * 1_000_000);
}

pub fn sleep_sec(sec: u64) void {
    std.Thread.sleep(sec * 1_000_000_000);
}

//=============================================================================
// Additional String Operations
//=============================================================================
/// Trims leading and trailing whitespace from a string
/// Example: const trimmed = trim("  hello  "); // "hello"
pub fn trim(s: []const u8) []const u8 {
    return std.mem.trim(u8, s, " \t\n\r");
}

/// Trims only leading whitespace from a string
/// Example: const trimmed = trim_left("  hello"); // "hello"
pub fn trim_left(s: []const u8) []const u8 {
    return std.mem.trimLeft(u8, s, " \t\n\r");
}

/// Trims only trailing whitespace from a string
/// Example: const trimmed = trim_right("hello  "); // "hello"
pub fn trim_right(s: []const u8) []const u8 {
    return std.mem.trimRight(u8, s, " \t\n\r");
}

/// Converts a string to uppercase
/// Memory must be freed by the caller using allocator.free()
/// Example: const upper = try to_upper(allocator, "hello"); // "HELLO"
pub fn to_upper(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, s.len);
    for (s, 0..) |c, i| {
        result[i] = if (c >= 'a' and c <= 'z') c - 32 else c;
    }
    return result;
}

/// Converts a string to lowercase
/// Memory must be freed by the caller using allocator.free()
/// Example: const lower = try to_lower(allocator, "HELLO"); // "hello"
pub fn to_lower(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, s.len);
    for (s, 0..) |c, i| {
        result[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    return result;
}

/// Checks if a string contains a substring
/// Example: if (contains("hello world", "world")) { ... }
pub fn contains(haystack: []const u8, needle: []const u8) bool {
    return std.mem.indexOf(u8, haystack, needle) != null;
}

/// Checks if a string starts with the given prefix
/// Example: if (starts_with("hello world", "hello")) { ... }
pub fn starts_with(s: []const u8, prefix: []const u8) bool {
    return std.mem.startsWith(u8, s, prefix);
}

/// Checks if a string ends with the given suffix
/// Example: if (ends_with("hello.txt", ".txt")) { ... }
pub fn ends_with(s: []const u8, suffix: []const u8) bool {
    return std.mem.endsWith(u8, s, suffix);
}

/// Replaces all occurrences of a pattern with replacement
/// Memory must be freed by the caller using allocator.free()
/// Example: const result = try replace(allocator, "hello world", "world", "zig");
pub fn replace(allocator: std.mem.Allocator, s: []const u8, pattern: []const u8, replacement: []const u8) ![]u8 {
    if (pattern.len == 0) {
        return allocator.dupe(u8, s);
    }

    var result = std.array_list.Managed(u8).init(allocator);
    errdefer result.deinit();

    var i: usize = 0;
    while (i < s.len) {
        if (i + pattern.len <= s.len and std.mem.eql(u8, s[i .. i + pattern.len], pattern)) {
            try result.appendSlice(replacement);
            i += pattern.len;
        } else {
            try result.append(s[i]);
            i += 1;
        }
    }

    return result.toOwnedSlice();
}

/// Repeats a string n times
/// Memory must be freed by the caller using allocator.free()
/// Example: const result = try repeat(allocator, "ab", 3); // "ababab"
pub fn repeat(allocator: std.mem.Allocator, s: []const u8, n: usize) ![]u8 {
    if (n == 0) return allocator.alloc(u8, 0);
    const result = try allocator.alloc(u8, s.len * n);
    for (0..n) |i| {
        @memcpy(result[i * s.len .. (i + 1) * s.len], s);
    }
    return result;
}

/// Counts occurrences of a substring in a string
/// Example: const count = count_substr("ababa", "aba"); // returns 1 (non-overlapping)
pub fn count_substr(haystack: []const u8, needle: []const u8) usize {
    if (needle.len == 0 or needle.len > haystack.len) return 0;
    var count: usize = 0;
    var i: usize = 0;
    while (i + needle.len <= haystack.len) {
        if (std.mem.eql(u8, haystack[i .. i + needle.len], needle)) {
            count += 1;
            i += needle.len;
        } else {
            i += 1;
        }
    }
    return count;
}

/// Returns the index of the first occurrence of needle in haystack, or null if not found
/// Example: const idx = index_of("hello", "ll"); // returns 2
pub fn index_of(haystack: []const u8, needle: []const u8) ?usize {
    return std.mem.indexOf(u8, haystack, needle);
}

//=============================================================================
// Additional Mathematical Functions
//=============================================================================
/// Tangent function for f32 using sin/cos
/// Example: const result = tan_f32(0.5);
pub fn tan_f32(x: f32) f32 {
    const c = cos_f32(x);
    if (c == 0) return std.math.inf(f32);
    return sin_f32(x) / c;
}

/// Tangent function for f64 using sin/cos
/// Example: const result = tan_f64(0.5);
pub fn tan_f64(x: f64) f64 {
    const c = cos_f64(x);
    if (c == 0) return std.math.inf(f64);
    return sin_f64(x) / c;
}

/// Generic minimum of two values
/// Example: const m = min(@as(i32, 5), @as(i32, 3)); // returns 3
pub fn min(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return if (a < b) a else b;
}

/// Generic maximum of two values
/// Example: const m = max(@as(i32, 5), @as(i32, 3)); // returns 5
pub fn max(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return if (a > b) a else b;
}

/// Clamps a value between min and max bounds
/// Example: const clamped = clamp(@as(i32, 15), 0, 10); // returns 10
pub fn clamp(value: anytype, min_val: @TypeOf(value), max_val: @TypeOf(value)) @TypeOf(value) {
    return max(min_val, min(max_val, value));
}

/// Calculates factorial of n (n!)
/// Returns 1 for n=0, and the product 1*2*...*n otherwise
/// Example: const result = factorial(5); // returns 120
pub fn factorial(n: u64) u64 {
    if (n <= 1) return 1;
    var result: u64 = 1;
    var i: u64 = 2;
    while (i <= n) : (i += 1) {
        result *= i;
    }
    return result;
}

/// Greatest common divisor using Euclidean algorithm
/// Example: const result = gcd(48, 18); // returns 6
pub fn gcd(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    var x = if (a < 0) -a else a;
    var y = if (b < 0) -b else b;
    while (y != 0) {
        const temp = y;
        y = @mod(x, y);
        x = temp;
    }
    return x;
}

/// Least common multiple
/// Example: const result = lcm(4, 6); // returns 12
pub fn lcm(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    if (a == 0 or b == 0) return 0;
    const abs_a = if (a < 0) -a else a;
    const abs_b = if (b < 0) -b else b;
    return @divExact(abs_a, gcd(a, b)) * abs_b;
}

/// Checks if a number is prime
/// Example: if (is_prime(17)) { ... }
pub fn is_prime(n: u64) bool {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    var i: u64 = 3;
    while (i * i <= n) : (i += 2) {
        if (n % i == 0) return false;
    }
    return true;
}

/// Converts degrees to radians
/// Example: const rad = deg_to_rad(180.0); // returns pi
pub fn deg_to_rad(deg: anytype) @TypeOf(deg) {
    const pi: @TypeOf(deg) = 3.14159265358979323846;
    return deg * pi / 180.0;
}

/// Converts radians to degrees
/// Example: const deg = rad_to_deg(pi); // returns 180.0
pub fn rad_to_deg(rad: anytype) @TypeOf(rad) {
    const pi: @TypeOf(rad) = 3.14159265358979323846;
    return rad * 180.0 / pi;
}

/// Linear interpolation between two values
/// t should be between 0 and 1
/// Example: const mid = lerp(0.0, 10.0, 0.5); // returns 5.0
pub fn lerp(a: anytype, b: @TypeOf(a), t: @TypeOf(a)) @TypeOf(a) {
    return a + (b - a) * t;
}

/// Inverse linear interpolation - finds t given a value between a and b
/// Example: const t = inv_lerp(0.0, 10.0, 5.0); // returns 0.5
pub fn inv_lerp(a: anytype, b: @TypeOf(a), value: @TypeOf(a)) @TypeOf(a) {
    if (b - a == 0) return 0;
    return (value - a) / (b - a);
}

/// Maps a value from one range to another
/// Example: const mapped = map_range(5.0, 0.0, 10.0, 0.0, 100.0); // returns 50.0
pub fn map_range(value: anytype, in_min: @TypeOf(value), in_max: @TypeOf(value), out_min: @TypeOf(value), out_max: @TypeOf(value)) @TypeOf(value) {
    return lerp(out_min, out_max, inv_lerp(in_min, in_max, value));
}

/// Sign function - returns -1, 0, or 1
/// Example: const s = sign(@as(i32, -5)); // returns -1
pub fn sign(x: anytype) @TypeOf(x) {
    if (x > 0) return 1;
    if (x < 0) return -1;
    return 0;
}

//=============================================================================
// Additional File Operations
//=============================================================================
/// Writes content to a file, creating it if it doesn't exist
/// Example: try write_file("output.txt", "Hello, World!");
pub fn write_file(path: []const u8, content: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();
    try file.writeAll(content);
}

/// Appends content to a file, creating it if it doesn't exist
/// Example: try append_file("log.txt", "New log entry\n");
pub fn append_file(path: []const u8, content: []const u8) !void {
    const file = std.fs.cwd().openFile(path, .{ .mode = .write_only }) catch |err| switch (err) {
        error.FileNotFound => try std.fs.cwd().createFile(path, .{}),
        else => return err,
    };
    defer file.close();
    try file.seekFromEnd(0);
    try file.writeAll(content);
}

/// Returns the size of a file in bytes
/// Example: const size = try file_size("data.txt");
pub fn file_size(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    return stat.size;
}

/// Checks if a file exists (either as file or directory)
/// Example: if (exists("config.txt")) { ... }
pub fn exists(path: []const u8) bool {
    return is_file(path) or is_dir(path);
}

//=============================================================================
// Array/Slice Utilities
//=============================================================================
fn SliceElementType(comptime T: type) type {
    const info = @typeInfo(T);
    if (info == .pointer) {
        const child = info.pointer.child;
        const child_info = @typeInfo(child);
        if (child_info == .array) {
            return child_info.array.child;
        }
        return child;
    }
    return void;
}

/// Sums all elements in a numeric slice
/// Example: const total = sum(&[_]i32{1, 2, 3, 4, 5}); // returns 15
pub fn sum(slice: anytype) SliceElementType(@TypeOf(slice)) {
    const T = SliceElementType(@TypeOf(slice));
    var total: T = 0;
    for (slice) |item| {
        total += item;
    }
    return total;
}

/// Calculates the average of a numeric slice (returns f64)
/// Example: const average = avg(&[_]i32{1, 2, 3, 4, 5}); // returns 3.0
pub fn avg(slice: anytype) f64 {
    if (slice.len == 0) return 0;
    var total: f64 = 0;
    for (slice) |item| {
        total += @as(f64, @floatFromInt(item));
    }
    return total / @as(f64, @floatFromInt(slice.len));
}

/// Reverses a slice in place
/// Example: var arr = [_]i32{1, 2, 3}; reverse(&arr); // arr is now {3, 2, 1}
pub fn reverse(slice: anytype) void {
    if (slice.len < 2) return;
    var left: usize = 0;
    var right: usize = slice.len - 1;
    while (left < right) {
        const temp = slice[left];
        slice[left] = slice[right];
        slice[right] = temp;
        left += 1;
        right -= 1;
    }
}

/// Binary search for a value in a sorted slice
/// Returns the index if found, null otherwise
/// Example: const idx = binary_search(&[_]i32{1, 3, 5, 7, 9}, 5); // returns 2
pub fn binary_search(slice: anytype, value: SliceElementType(@TypeOf(slice))) ?usize {
    if (slice.len == 0) return null;
    var left: usize = 0;
    var right: usize = slice.len;
    while (left < right) {
        const mid = left + (right - left) / 2;
        if (slice[mid] == value) {
            return mid;
        } else if (slice[mid] < value) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return null;
}

/// Finds the minimum value in a slice
/// Returns null for empty slices
/// Example: const minimum = slice_min(&[_]i32{5, 2, 8, 1}); // returns 1
pub fn slice_min(slice: anytype) ?SliceElementType(@TypeOf(slice)) {
    if (slice.len == 0) return null;
    var minimum = slice[0];
    for (slice[1..]) |item| {
        if (item < minimum) minimum = item;
    }
    return minimum;
}

/// Finds the maximum value in a slice
/// Returns null for empty slices
/// Example: const maximum = slice_max(&[_]i32{5, 2, 8, 1}); // returns 8
pub fn slice_max(slice: anytype) ?SliceElementType(@TypeOf(slice)) {
    if (slice.len == 0) return null;
    var maximum = slice[0];
    for (slice[1..]) |item| {
        if (item > maximum) maximum = item;
    }
    return maximum;
}

//=============================================================================
// Additional Random Number Generation
//=============================================================================
/// Generates a random f32 in the range [0, 1)
/// Example: const f = rng_f32(); // random float between 0 and 1
pub fn rng_f32() f32 {
    const bits = random.int(u32);
    return @as(f32, @floatFromInt(bits >> 8)) / @as(f32, 1 << 24);
}

/// Generates a random f64 in the range [0, 1)
/// Example: const f = rng_f64(); // random float between 0 and 1
pub fn rng_f64() f64 {
    const bits = random.int(u64);
    return @as(f64, @floatFromInt(bits >> 11)) / @as(f64, 1 << 53);
}

/// Generates a random f32 in the specified range [min, max)
/// Example: const f = rng_f32_range(1.0, 10.0);
pub fn rng_f32_range(min_val: f32, max_val: f32) f32 {
    return min_val + rng_f32() * (max_val - min_val);
}

/// Generates a random f64 in the specified range [min, max)
/// Example: const f = rng_f64_range(1.0, 10.0);
pub fn rng_f64_range(min_val: f64, max_val: f64) f64 {
    return min_val + rng_f64() * (max_val - min_val);
}

/// Generates a random boolean
/// Example: if (rng_bool()) { ... }
pub fn rng_bool() bool {
    return random.boolean();
}

/// Shuffles a slice in place using Fisher-Yates algorithm
/// Example: var arr = [_]i32{1, 2, 3, 4, 5}; shuffle(&arr);
pub fn shuffle(slice: anytype) void {
    if (slice.len < 2) return;
    var i: usize = slice.len - 1;
    while (i > 0) : (i -= 1) {
        const j = random.intRangeAtMost(usize, 0, i);
        const temp = slice[i];
        slice[i] = slice[j];
        slice[j] = temp;
    }
}

/// Picks a random element from a slice
/// Returns null for empty slices
/// Example: const item = rng_choice(&[_]str{"a", "b", "c"});
pub fn rng_choice(slice: anytype) ?SliceElementType(@TypeOf(slice)) {
    if (slice.len == 0) return null;
    const idx = random.intRangeAtMost(usize, 0, slice.len - 1);
    return slice[idx];
}

//=============================================================================
// Bit Manipulation Utilities
//=============================================================================
/// Counts the number of set bits (1s) in an integer
/// Example: const count = popcount(@as(u8, 0b10110)); // returns 3
pub fn popcount(x: anytype) u32 {
    return @popCount(x);
}

/// Returns the number of leading zeros in an integer
/// Example: const zeros = leading_zeros(@as(u8, 0b00001000)); // returns 4
pub fn leading_zeros(x: anytype) u32 {
    return @clz(x);
}

/// Returns the number of trailing zeros in an integer
/// Example: const zeros = trailing_zeros(@as(u8, 0b00001000)); // returns 3
pub fn trailing_zeros(x: anytype) u32 {
    return @ctz(x);
}

/// Checks if a number is a power of two
/// Example: if (is_power_of_two(8)) { ... } // true
pub fn is_power_of_two(x: anytype) bool {
    return x > 0 and (x & (x - 1)) == 0;
}

/// Returns the next power of two >= x
/// Example: const next = next_power_of_two(@as(u32, 5)); // returns 8
pub fn next_power_of_two(x: anytype) @TypeOf(x) {
    if (x == 0) return 1;
    if (is_power_of_two(x)) return x;
    const T = @TypeOf(x);
    const bits = @bitSizeOf(T);
    const shift: std.math.Log2Int(T) = @intCast(bits - @clz(x));
    return @as(T, 1) << shift;
}
