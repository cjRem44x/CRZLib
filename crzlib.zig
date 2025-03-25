// AUTHOR: CJ Remillard
//
pub const std = @import("std");
pub const print = std.debug.print;
pub const str = []const u8;
//
// C Libs
pub const cstdlib = @cImport( @cInclude("stdlib.h") );


// LIB ERROR //
//
pub fn liberr(report: str) void {
    strout("\n@CRZLib(**ERROR**) >> ");
    strout(report);
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
	term(&[_][]const u8{"cmd", "/C", "start", url}) catch liberr("Failed to open URL!\n");
}
//
pub fn open_file(file_path: []const u8) void {
    term(&[_][]const u8{"cmd", "/C", "start", file_path}) catch liberr("Failed to open file!\n");
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
pub fn strcat(alloc: std.mem.Allocator, s1: []const u8, s2: []const u8) ![]const u8 {
    return std.mem.concat(alloc, u8, &[_][]const u8{ s1, s2 });
}


// RANDOM NUMBERS //
//
pub fn rng_i32(min: i32, max: i32) i32 {
    const random = std.crypto.random;
    if (max-min > 0) {
        return random.intRangeAtMost(i32, min, max);
    } else {
        return min;
    }
}
//
pub fn rng_i64(min: i64, max: i64) i64 {
    const random = std.crypto.random;
    if (max-min > 0) {
        return random.intRangeAtMost(i64, min, max);
    } else {
        return min;
    }
}
//
pub fn rng_i128(min: i128, max: i128) i128 {
    const random = std.crypto.random;
    if (max-min > 0) {
        return random.intRangeAtMost(i128, min, max);
    } else {
        return min;
    }
}


// SQRT SHORTCUT //
//
// double guess = number / 2; // Initial guess
//         double precision = 1e-6;  // Precision threshold

//         while (Math.abs(guess * guess - number) > precision) {
//             guess = (guess + number / guess) / 2; // Update guess
//         }
pub fn sqrt_f64(n: f64) f64 {
    var guess: f64 = n/2.00;
    const precision: f64 = 1e-6;

    while (abs(guess*guess - n) > precision) {
        guess = (guess + n / guess) / 2;
    }
    return guess;
}
//
fn abs(n: f64) f64 {
    if (n < 0) {
        return n*-1.00;
    } 
    return n;
}
//
pub fn sqrt(x: anytype) Sqrt(@TypeOf(x)) {
    return std.math.sqrt(x);
} 
//
pub fn inv_sqrt(x: anytype) Sqrt(@TypeOf(x)) {
    return 1.00/std.math.sqrt(x);
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


// STRING TO CONSOLE //
//
pub fn strout(s: []const u8) void {
    print("{s}", .{s});
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
