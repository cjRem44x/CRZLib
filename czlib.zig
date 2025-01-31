pub const std = @import("std");
pub const print = std.debug.print;
pub const str = []const u8;

// Random I32 Ints //
pub fn rng(min: i32, max: i32) i32 {
    const random = std.crypto.random;
    return random.intRangeAtMost(i32, min, max);
}

// Print string to console //
pub fn strout(s: []const u8) void {
    print("{s}", .{s});
}

// Console input //
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
