const std = @import("std");
const g_engine = @import("g_engine");

const Engine = g_engine.Engine;

pub fn main(init: std.process.Init) !void {
    var engine: *Engine = try .init(init.gpa);
    defer {
        engine.shutdown();
        engine.deinit(init.gpa);
    }

    try engine.run();
}
