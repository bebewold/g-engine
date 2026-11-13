const std = @import("std");
const g_engine = @import("g_engine");

pub fn main(init: std.process.Init) !void {
    var arena = init.arena;
    const allocator = arena.allocator();

    var engine: g_engine.Engine = try .init(allocator);
    defer engine.shutdown();
    try engine.run();
}
