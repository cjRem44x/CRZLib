// AUTHOR: CJ Remillard //
//
pub const std = @import("std");
pub const print = std.debug.print;
pub const str = []const u8;


// LIB ERROR //
//
pub fn liberr(report: str) void {
    strout("\n@CRZLib(**ERROR**) >> ");
    strout(report);
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
