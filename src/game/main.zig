const std = @import("std");
const g_engine = @import("g_engine");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var engine: g_engine.Engine = try .init(allocator);
    defer engine.shutdown();
    try engine.run();
}
