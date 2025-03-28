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

/// CRZLib Allocator Benchmark
/// This program benchmarks different Zig allocators to compare their performance
/// in terms of allocation and deallocation speed.
///
/// Tested Allocators:
/// - Page Allocator: The default system allocator
/// - Arena Allocator: Fast for LIFO allocations
/// - Fixed Buffer Allocator: Fast but with fixed size limit
/// - General Purpose Allocator: Balanced performance and features
///
/// The test performs multiple iterations of allocating and freeing memory blocks
/// to measure the performance characteristics of each allocator.
const std = @import("std");
const print = std.debug.print;
const time = std.time;
const Allocator = std.mem.Allocator;
const page_allocator = std.heap.page_allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;

// Test Configuration
const NUM_ITERATIONS = 1000; // Increased for more accurate measurements
const NUM_ALLOCATIONS = 100; // Keep reasonable to prevent memory issues
const ALLOC_SIZE = 64; // Keep small for quick allocations
const FIXED_BUFFER_SIZE = 1024 * 1024; // 1MB buffer for Fixed Buffer Allocator

/// Test function that benchmarks an allocator's performance
/// Parameters:
///   allocator: The allocator to test
///   name: Name of the allocator for reporting
fn testAllocator(allocator: Allocator, name: []const u8) !void {
    print("\nTesting {s}:\n", .{name});
    print("----------------------------------------\n", .{});

    // Warm-up phase
    print("Warming up...\n", .{});
    var warmup_allocations = std.ArrayList([]u8).init(allocator);
    defer warmup_allocations.deinit();

    for (0..10) |_| {
        const ptr = try allocator.alloc(u8, ALLOC_SIZE);
        try warmup_allocations.append(ptr);
    }

    for (warmup_allocations.items) |ptr| {
        allocator.free(ptr);
    }

    // Main test phase
    print("Running main test...\n", .{});
    var allocations = std.ArrayList([]u8).init(allocator);
    defer allocations.deinit();

    const start_time = time.nanoTimestamp();

    for (0..NUM_ITERATIONS) |i| {
        if (i % 100 == 0) {
            print("Progress: {d}%\n", .{(i * 100) / NUM_ITERATIONS});
        }

        for (0..NUM_ALLOCATIONS) |_| {
            const ptr = allocator.alloc(u8, ALLOC_SIZE) catch |err| {
                print("Allocation failed: {s}\n", .{@errorName(err)});
                return err;
            };
            try allocations.append(ptr);
        }

        // Free all allocations
        for (allocations.items) |ptr| {
            allocator.free(ptr);
        }
        allocations.clearRetainingCapacity();
    }

    const end_time = time.nanoTimestamp();
    const total_ns = end_time - start_time;
    const total_time = @as(f64, @floatFromInt(total_ns)) / 1_000_000_000.0;
    const avg_time = @as(f64, @floatFromInt(total_ns)) / @as(f64, @floatFromInt(NUM_ITERATIONS));
    const ops_per_second = if (avg_time > 0)
        @as(f64, @floatFromInt(NUM_ALLOCATIONS * 2)) / (avg_time / 1_000_000_000.0)
    else
        0.0;

    print("Results:\n", .{});
    print("  Total time: {d:.3} seconds\n", .{total_time});
    print("  Average time per iteration: {d:.3} microseconds\n", .{avg_time / 1000.0});
    print("  Operations per second: {d:.2}\n", .{ops_per_second});
    print("  Memory used per iteration: {d} bytes\n", .{NUM_ALLOCATIONS * ALLOC_SIZE});
    print("  Total memory allocated: {d:.2} MB\n", .{@as(f64, @floatFromInt(NUM_ITERATIONS * NUM_ALLOCATIONS * ALLOC_SIZE)) / (1024.0 * 1024.0)});
}

pub fn main() !void {
    print("CRZLib Allocator Benchmark\n", .{});
    print("=========================\n", .{});
    print("Configuration:\n", .{});
    print("  Iterations: {d}\n", .{NUM_ITERATIONS});
    print("  Allocations per iteration: {d}\n", .{NUM_ALLOCATIONS});
    print("  Allocation size: {d} bytes\n", .{ALLOC_SIZE});
    print("  Fixed buffer size: {d} bytes\n", .{FIXED_BUFFER_SIZE});
    print("\n", .{});

    // Test Page Allocator
    try testAllocator(page_allocator, "Page Allocator");

    // Test Arena Allocator
    var arena = ArenaAllocator.init(page_allocator);
    defer arena.deinit();
    try testAllocator(arena.allocator(), "Arena Allocator");

    // COMMENTED OUT BECAUSE OF ERRORS
    //
    // Test Fixed Buffer Allocator
    //var buffer: [FIXED_BUFFER_SIZE]u8 = undefined;
    //var fba = FixedBufferAllocator.init(&buffer);
    //try testAllocator(fba.allocator(), "Fixed Buffer Allocator");

    // Test General Purpose Allocator
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try testAllocator(gpa.allocator(), "General Purpose Allocator");
}
