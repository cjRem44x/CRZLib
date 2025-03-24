const crz = @import("crzlib.zig");

pub fn main() !void {
    const pa = crz.std.heap.page_allocator;
    const n = try crz.strcat(pa, "hello", "hello");
    defer pa.free(n);

    crz.print("{s}\n", .{n});
}
