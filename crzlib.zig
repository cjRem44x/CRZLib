// AUTHOR: CJ Remillard
//
pub const std = @import("std");
pub const print = std.debug.print;
pub const str = []const u8;
//
// C Libs
pub const cstdlib = @cImport(@cInclude("stdlib.h"));

// LIB ERROR //
//
pub fn liberr(report: str) void {
    strout("\n@CRZLib(**ERROR**) >> ");
    strout(report);
}

// COMMAND LINE ARGS //
//
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
/// Checks if the given path is a directory
pub fn is_dir(path: []const u8) bool {
    var dir = std.fs.cwd().openDir(path, .{}) catch return false;
    defer dir.close();
    return true;
}

// C STDLIB //
//
// NOTE:
pub fn c_system(s: [*c]const u8) void {
    _ = cstdlib.system(s);
}

// ZIG TERMINAL //
//
// NOTE: use '&[_][]const u8{"zig", "zen"}' for
// array of strings.
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
pub fn open_url(url: []const u8) void {
    term(&[_][]const u8{ "explorer", url }) catch liberr("Failed to open URL!\n");
}
//
pub fn open_file(file_path: []const u8) void {
    term(&[_][]const u8{ "cmd", "/C", "start", file_path }) catch liberr("Failed to open file!\n");
}

// STRING FUNCS //
//
pub fn streql(s1: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s1, s2);
}
//
// NOTE: to use 'cat()' an allocator from std.heap.*
// must be provided.
// NOTE: after allocating space of returned string
// it is recommended to use 'defer allocator.free(
// result_string)'
pub fn strcat(allocator: std.mem.Allocator, s1: []const u8, s2: []const u8) ![]const u8 {
    return std.mem.concat(allocator, u8, &[_][]const u8{ s1, s2 });
}
//
//
// Split string based on pattern
pub fn strsplit(input: []const u8, pattern: []const u8) ![][]const u8 {
    const allocator = std.heap.page_allocator;

    // Create an array to store split substrings
    var results = std.ArrayList([]const u8).init(allocator);
    defer results.deinit();

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
//
fn abs_f64(n: f64) f64 {
    if (n < 0) {
        return n * -1.00;
    }
    return n;
}
//
pub fn sqrt(x: anytype) Sqrt(@TypeOf(x)) {
    return std.math.sqrt(x);
}
//
pub fn inv_sqrt(x: anytype) Sqrt(@TypeOf(x)) {
    return 1.00 / std.math.sqrt(x);
}
//
// From Zig Lib ->
/// Returns the return type `sqrt` will return given an operand of type `T`.
pub fn Sqrt(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .int => |int| @Type(.{ .int = .{ .signedness = .unsigned, .bits = (int.bits + 1) / 2 } }),
        else => T,
    };
}

// POWER OF //
//
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
pub fn strout(s: []const u8) void {
    print("{s}", .{s});
}
//
// NOTE: use 'log()' to print to the console,
// with new line -- similar to println().
pub fn log(s: []const u8) void {
    print("{s}\n", .{s});
}

// CONSOLE INPUT //
//
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
