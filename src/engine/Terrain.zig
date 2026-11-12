const std = @import("std");
const sdl = @import("sdl");

const Terrain = @This();

bounds: sdl.SDL_FRect,

pub fn keep_in_bounds(self: *const Terrain, rect: *sdl.SDL_FRect) void {
    const boundaries: Boundaries = .init(self.bounds);
    const other_boundaries: Boundaries = .init(rect.*);

    rect.x = if (boundaries.left >= other_boundaries.left) boundaries.left else if (boundaries.right <= other_boundaries.right) boundaries.right - rect.w else rect.x;

    rect.y = if (boundaries.top >= other_boundaries.top) boundaries.top else if (boundaries.bottom <= other_boundaries.bottom) boundaries.bottom - rect.h else rect.y;
}

const Boundaries = struct {
    top: f32,
    bottom: f32,
    left: f32,
    right: f32,

    fn init(rect: sdl.SDL_FRect) Boundaries {
        return .{
            .top = rect.y,
            .bottom = rect.y + rect.h,
            .left = rect.x,
            .right = rect.x + rect.w,
        };
    }
};
