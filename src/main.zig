const std = @import("std");
const g_engine = @import("g_engine");



pub fn main() !void {
    var game = try g_engine.init();

    game.run();
}

