const cz = @import("czlib.zig");

pub fn main() !void {
    var buf: [10]u8 = undefined;
    const name = try cz.cin(&buf, "enter name: ");
    cz.print("hello {s}\n", .{name});

    cz.liberr("testing");
}
