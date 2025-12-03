// MIT License - Copyright (c) 2024 CJ Remillard

/// Mathematical Functions Example
/// Demonstrates mathematical functions from CRZLib including sqrt, trig, and RNG
const crz = @import("crzlib");
const std = @import("std");

pub fn main() !void {
    crz.log("=== CRZLib Mathematical Functions Example ===\n");

    // Square root tests
    crz.log("Square Root Functions:");
    const numbers = [_]f64{ 4.0, 16.0, 25.0, 100.0, 2.0 };
    for (numbers) |n| {
        crz.strout("  sqrt(");
        crz.strout(std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{n}) catch "?");
        crz.strout(") = ");
        crz.logn(crz.sqrt_f64(n));
    }

    // Inverse square root
    crz.log("\nInverse Square Root Functions:");
    for (numbers) |n| {
        crz.strout("  inv_sqrt(");
        crz.strout(std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{n}) catch "?");
        crz.strout(") = ");
        crz.logn(crz.inv_sqrt_f64(n));
    }

    // Trigonometric functions
    crz.log("\nTrigonometric Functions:");
    const angles = [_]f64{ 0.0, 0.785398, 1.5708, 3.14159 }; // 0, π/4, π/2, π
    for (angles) |angle| {
        crz.strout("  sin(");
        crz.strout(std.fmt.allocPrint(std.heap.page_allocator, "{d:.4}", .{angle}) catch "?");
        crz.strout(") = ");
        crz.logn(crz.sin_f64(angle));
    }
    crz.log("");
    for (angles) |angle| {
        crz.strout("  cos(");
        crz.strout(std.fmt.allocPrint(std.heap.page_allocator, "{d:.4}", .{angle}) catch "?");
        crz.strout(") = ");
        crz.logn(crz.cos_f64(angle));
    }

    // Power function
    crz.log("\nPower Function:");
    crz.strout("  2^3 = ");
    crz.logn(crz.pow(2, 3));
    crz.strout("  5^2 = ");
    crz.logn(crz.pow(5, 2));
    crz.strout("  10^0 = ");
    crz.logn(crz.pow(10, 0));

    // Random number generation
    crz.log("\nRandom Number Generation:");
    crz.log("  10 random numbers between 1-100:");
    crz.strout("  ");
    for (0..10) |_| {
        crz.strout(std.fmt.allocPrint(std.heap.page_allocator, "{d} ", .{crz.rng_i32(1, 100)}) catch "?");
    }
    crz.log("");

    crz.log("\nMathematical functions completed successfully!");
}
