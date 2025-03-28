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
//
// C Libs
pub const cstdlib = @cImport(@cInclude("stdlib.h"));

// LIB ERROR //
//
/// Error Reporting
/// Prints formatted error messages with the CRZLib prefix
pub fn liberr(report: str) void {
    strout("\n@CRZLib(**ERROR**) >> ");
    strout(report);
}

// COMMAND LINE ARGS //
//
/// Command Line Arguments
/// Returns an array of command line arguments (excluding program name)
/// Memory must be freed by the caller
pub fn get_args(allocator: std.mem.Allocator) ![][]const u8 {
    // Get the argument iterator from the standard library
    var arg_it = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, arg_it);

    // Create a new array to store the arguments (skipping the first arg, which is the program name)
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();

    // Skip the first argument (program name) and copy the rest
    for (arg_it[1..]) |arg| {
        const arg_copy = try allocator.dupe(u8, arg);
        try args.append(arg_copy);
    }

    // Return the slice of arguments
    return args.toOwnedSlice();
}

// READ FILE //
//
/// File Operations
/// Reads a file and returns its contents as an array of strings (one per line)
/// Memory must be freed by the caller
pub fn read_file(allocator: std.mem.Allocator, path: []const u8) ![][]const u8 {
    // Open the file
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    // Create a dynamic array to store lines
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    // Read file line by line
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Trim whitespace and create a copy of the line
        //const trimmed_line = std.mem.trim(u8, line, " \r\n");
        const line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
    }

    // Return the array of lines
    return lines.toOwnedSlice();
}
//
//
/// File System Checks
/// Returns true if the path points to a file
pub fn is_file(path: []const u8) bool {
    const stat = std.fs.cwd().statFile(path) catch |err| switch (err) {
        error.FileNotFound => return false,
        error.IsDir => return false,
        else => return false,
    };
    _ = stat;

    // If we've reached this point, it's a file
    return true;
}
//
/// Directory Checks
/// Returns true if the path points to a directory
pub fn is_dir(path: []const u8) bool {
    var dir = std.fs.cwd().openDir(path, .{}) catch return false;
    defer dir.close();
    return true;
}

// C STDLIB //
//
/// System Commands
/// Executes a system command using the C standard library
pub fn c_system(s: [*c]const u8) void {
    _ = cstdlib.system(s);
}

// ZIG TERMINAL //
//
// NOTE: use '&[_][]const u8{"zig", "zen"}' for
// array of strings.
/// Terminal Commands
/// Executes a command in the terminal and returns its output
pub fn term(argv: []const []const u8) !void {
    // Create an arena allocator for memory management
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Execute the command
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });

    // Print the output of the command
    std.debug.print("{s}\n", .{result.stdout});
}

// OS DEPENDENT //
//
// NOTE: this function may only work Windows.
/// OS-Specific Functions
/// Opens a URL in the default browser (Windows only)
pub fn open_url(url: []const u8) void {
    term(&[_][]const u8{ "explorer", url }) catch liberr("Failed to open URL!\n");
}
//
/// Opens a file with the default application (Windows only)
pub fn open_file(file_path: []const u8) void {
    term(&[_][]const u8{ "cmd", "/C", "start", file_path }) catch liberr("Failed to open file!\n");
}

// STRING FUNCS //
//
/// String Operations
/// Compares two strings for equality
pub fn streql(s1: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s1, s2);
}
//
// NOTE: to use 'cat()' an allocator from std.heap.*
// must be provided.
// NOTE: after allocating space of returned string
// it is recommended to use 'defer allocator.free(
// result_string)'
/// Concatenates two strings
/// Memory must be freed by the caller
pub fn strcat(allocator: std.mem.Allocator, s1: []const u8, s2: []const u8) ![]const u8 {
    return std.mem.concat(allocator, u8, &[_][]const u8{ s1, s2 });
}
//
//
// Split string based on pattern
/// Splits a string based on a pattern
/// Memory must be freed by the caller
pub fn strsplit(input: []const u8, pattern: []const u8) ![][]const u8 {
    const allocator = std.heap.page_allocator;
    var results = std.ArrayList([]const u8).init(allocator);
    errdefer results.deinit();

    // If delimiter is empty, return the entire input as a single item
    if (pattern.len == 0) {
        const copy = try allocator.dupe(u8, input);
        try results.append(copy);
        return results.toOwnedSlice();
    }

    var start: usize = 0;
    while (std.mem.indexOf(u8, input[start..], pattern)) |pos| {
        // Extract the substring before the delimiter
        if (pos > 0) {
            const substring = try allocator.dupe(u8, input[start .. start + pos]);
            try results.append(substring);
        }

        // Move past the delimiter
        start += pos + pattern.len;
    }

    // Add the remaining part of the string
    if (start < input.len) {
        const substring = try allocator.dupe(u8, input[start..]);
        try results.append(substring);
    }

    // Return the array of substrings
    return results.toOwnedSlice();
}

// RANDOM NUMBERS //
//
/// Random Number Generation
/// Generates random integers in the specified range
pub fn rng_i32(min: i32, max: i32) i32 {
    const random = std.crypto.random;
    if (max - min > 0) {
        return random.intRangeAtMost(i32, min, max);
    } else {
        return min;
    }
}
//
pub fn rng_i64(min: i64, max: i64) i64 {
    const random = std.crypto.random;
    if (max - min > 0) {
        return random.intRangeAtMost(i64, min, max);
    } else {
        return min;
    }
}
//
pub fn rng_i128(min: i128, max: i128) i128 {
    const random = std.crypto.random;
    if (max - min > 0) {
        return random.intRangeAtMost(i128, min, max);
    } else {
        return min;
    }
}
//
pub fn rng_usize(min: usize, max: usize) usize {
    const random = std.crypto.random;
    if (max - min > 0) {
        return random.intRangeAtMost(usize, min, max);
    } else {
        return min;
    }
}

// SQRT SHORTCUT //
//
/// Mathematical Functions
/// Calculates square root using Newton's method
pub fn sqrt_f64(n: f64) f64 {
    if (n < 0.0) {
        liberr("Cannot square root negative float!\n");
        return 0.0;
    }

    if (n == 1.0 or n == 0.0) {
        return n;
    }

    var guess: f64 = n / 2.00;
    const precision: f64 = 1e-6;

    while (abs_f64(guess * guess - n) > precision) {
        guess = (guess + n / guess) / 2;
    }
    return guess;
}

/// Helper function for sqrt_f64
fn abs_f64(n: f64) f64 {
    if (n < 0) {
        return n * -1.00;
    }
    return n;
}

/// Inverse square root
pub fn inv_sqrt(x: f64) f64 {
    return 1.00 / sqrt_f64(x);
}

// POWER OF //
//
/// Power function
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

// STRING TO CONSOLE //
//
/// Console Output
/// Prints a string without a newline
pub fn strout(s: []const u8) void {
    print("{s}", .{s});
}
//
// NOTE: use 'log()' to print to the console,
// with new line -- similar to println().
/// Prints a string with a newline
pub fn log(s: []const u8) void {
    print("{s}\n", .{s});
}

// CONSOLE INPUT //
//
/// Console Input
/// Reads a line from stdin with a prompt
pub fn cin(buf: []u8, prompt: []const u8) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    strout(prompt);
    const line = (try stdin.readUntilDelimiterOrEof(buf, '\n')) orelse return "";
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trim(u8, line, "\r");
    } else {
        return line;
    }
}

// PARSE TO NUMS //
//
/// Number Parsing
/// Converts strings to various numeric types
/// Returns 0 or 0.0 if parsing fails
pub fn str_i8(s: []const u8) i8 {
    const n = std.fmt.parseInt(i8, s, 10) catch 0;
    return n;
}
//
pub fn str_i16(s: []const u8) i16 {
    const n = std.fmt.parseInt(i16, s, 10) catch 0;
    return n;
}
//
pub fn str_i32(s: []const u8) i32 {
    const n = std.fmt.parseInt(i32, s, 10) catch 0;
    return n;
}
//
pub fn str_i64(s: []const u8) i64 {
    const n = std.fmt.parseInt(i64, s, 10) catch 0;
    return n;
}
//
pub fn str_i128(s: []const u8) i128 {
    const n = std.fmt.parseInt(i128, s, 10) catch 0;
    return n;
}
//
// parse floats
pub fn str_f32(s: []const u8) f32 {
    const n = std.fmt.parseFloat(f32, s) catch 0.0;
    return n;
}
//
pub fn str_f64(s: []const u8) f64 {
    const n = std.fmt.parseFloat(f64, s) catch 0.0;
    return n;
}
//
pub fn str_f128(s: []const u8) f128 {
    const n = std.fmt.parseFloat(f128, s) catch 0.0;
    return n;
}
