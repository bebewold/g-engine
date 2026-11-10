const std = @import("std");
const sdl = @import("sdl");
const utils = @import("utils.zig");

pub const Atlas = @This();

texture: *sdl.SDL_Texture,
texture_width: f32,
texture_height: f32,

pub fn init(
    renderer: *sdl.SDL_Renderer,
    file_path: [:0]const u8,
) !Atlas {
    const surface = sdl.IMG_Load(file_path);
    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface) orelse {
        return error.SDLError;
    };
    sdl.SDL_DestroySurface(surface);

    // safety purposes
    var tex_w: f32 = 0;
    var tex_h: f32 = 0;
    if (!sdl.SDL_GetTextureSize(texture, &tex_w, &tex_h)) {
        return error.SDLError;
    }

    return Atlas{
        .texture = texture,
        .texture_width = tex_w,
        .texture_height = tex_h,
    };
}

// this function assumes that related frames are:
// - on the same row
// - the same length
// else it will break
pub fn slice(
    self: Atlas,
    allocator: std.mem.Allocator,
    coords: struct { x: f32, y: f32 },
    size: struct { w: f32, h: f32 },
    length: u8,
) ![]sdl.SDL_FRect {
    const end_x = coords.x + (size.w * length);
    const end_y = coords.y + size.h;

    if (end_x > self.texture_width) {
        return error.AtlasOutOfBounds;
    }
    if (end_y > self.texture_height) {
        return error.AtlasOutOfBounds;
    }

    const arr = try allocator.alloc(sdl.SDL_FRect, length);

    for (0..length) |i| {
        const x_pos = coords.x + (utils.FfromI(f32, i) * size.w);
        const y_pos = coords.y;

        arr[i] = sdl.SDL_FRect{
            .x = x_pos,
            .y = y_pos,
            .w = size.w,
            .h = size.h,
        };
    }

    return arr;
}

const testing = std.testing;
test "init func" {
    var window: ?*sdl.SDL_Window = null;
    var renderer: ?*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Starting game", 800, 600, sdl.SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        sdl.SDL_Log("Window / Renderer creation failed: %s", sdl.SDL_GetError());
        return error.SDLError;
    }

    _ = try Atlas.init(
        renderer.?,
        "./texture/mock.png",
    );

    try testing.expectError(error.SDLError, Atlas.init(
        renderer.?,
        "./texture/not_existant.png",
    ));
}

test "slice func" {
    const allocator = std.heap.page_allocator; // for the sake of testing

    var window: ?*sdl.SDL_Window = null;
    var renderer: ?*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Starting game", 800, 600, sdl.SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        sdl.SDL_Log("Window / Renderer creation failed: %s", sdl.SDL_GetError());
        return error.SDLError;
    }

    const atlas: Atlas = try .init(
        renderer.?,
        "./texture/mock.png",
    );

    const animation = try atlas.slice(allocator, .{ .x = 1, .y = 1 }, .{ .w = 16, .h = 16 }, 4);
    try testing.expect(animation.len == 4);

    try testing.expectError(error.AtlasOutOfBounds, atlas.slice(
        allocator,
        .{ .x = 1, .y = 1 },
        .{ .w = 16, .h = 16 },
        250,
    ));

    try testing.expectError(error.AtlasOutOfBounds, atlas.slice(
        allocator,
        .{ .x = 1, .y = 1 },
        .{ .w = 16, .h = 40000000000 },
        1,
    ));
}
