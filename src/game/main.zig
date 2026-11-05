const std = @import("std");
const g_engine = @import("g_engine");

pub fn main() !void {
    var engine: g_engine.Engine = try .init();
    defer engine.shutdown();
    engine.run();
}
