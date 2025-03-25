const crz = @import("crzlib.zig");

pub fn main() !void {
    test_c_system();
}

fn test_c_system() void {
    crz.c_system("dir");
}

fn test_rng() void {
    crz.strout(":: TESTING RNG ::\n");
    crz.strout("RNG i32\n");
    for (1..10) |_| {
        crz.print("{d} ", .{crz.rng_i32(1, 2_147_483_647)});
    }
    crz.strout("\nRNG i64\n");
    for (1..10) |_| {
        crz.print("{d} ", .{crz.rng_i64(1, 9_223_372_036_854_775_807)});
    }
    crz.strout("\nRNG i128\n");
    for (1..10) |_| {
        crz.print("{d} ", .{crz.rng_i128(1, 19_223_372_036_854_775_807)});
    }
}
