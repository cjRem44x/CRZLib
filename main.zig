const crz = @import("crzlib.zig");

pub fn main() !void {
    test_strsplit();
}

fn test_strsplit() void {
    const str = "foo:bar:baz";
    const split = crz.strsplit(str, ":") catch {
        crz.strout("Failed to split string!\n");
        return;
    };
    for (split) |s| {
        crz.print("{s}\n", .{s});
    }
}

fn test_file_sys() void {
    crz.print("real file = {}\n", .{crz.is_file("main.zig")});
    crz.print("real file = {}\n", .{crz.is_file("helloworld.zig")});

    crz.print("real dir = {}\n", .{crz.is_dir("C:\\Users\\cremi\\Desktop\\C")});
}

fn test_log() void {
    crz.log("Hello, World!");
    crz.log("foo bar");
}

fn test_sqrt() void {
    const n = 3.14;

    crz.print("{d}\n", .{crz.sqrt(n)});

    crz.print("{d}\n", .{crz.sqrt_f64(n)});
}

fn test_term() void {
    crz.term(&[_][]const u8{ "cmd", "/C" }) catch crz.strout("Terminal Write Failed!\n");
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
