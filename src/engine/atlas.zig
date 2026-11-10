const std = @import("std");
const sdl = @import("sdl");

const Atlas = @This();

texture: *sdl.SDL_Texture,
// texture_width : u16,
// texture_height: u16, 
arena  : std.heap.ArenaAllocator,


pub fn init(
    renderer : *sdl.SDL_Renderer,
    file_path: [:0]const u8,
    allocator: std.mem.Allocator,
) !Atlas {
    const arena = std.heap.ArenaAllocator.init(allocator);    

    const surface = sdl.IMG_Load(file_path);
    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface) orelse {
        return error.SDLError;
    };
    sdl.SDL_DestroySurface(surface);


    // safety purposes
    // need render.h
    // var tex_w: c_int = 0;
    // var tex_h: c_int = 0;
    // try sdl.SDL_QueryTexture(texture, null, null, &tex_w, &tex_h);

    return Atlas {
       .texture = texture, 
       //.texture_width = tex_w,
       //.texture_height = tex_h,
       .arena = arena,
    };
}


// this function assumes that related frames are:
// - on the same row
// - the same length
// else it will break
pub fn get(
    self: *Atlas,
    coords: struct {x:u16, y:u16},
    size  : struct {w:u16, h:u16},
    length: u8
) ![] sdl.SDL_FRect {
    // const end_x = coords.x + (size.w * length);
    // const end_y = coords.y + size.h;
       
    // if ( end_x > self.texture_width) {
    //     return error.AtlasOutOfBounds;
    // }
    // if ( end_y > self.texture_height) {
    //     return error.AtlasOutOfBounds;
    // }

    const allocator = self.arena.allocator();
    const slice = try allocator.alloc(sdl.SDL_FRect, length);
    
    for (0..length) |i| {
        const x_pos = @as(f32, @floatFromInt(coords.x)) + (@as(f32, @floatFromInt(i)) * @as(f32, @floatFromInt(size.w)));
        const y_pos = @as(f32, @floatFromInt(coords.y));

        slice[i] = sdl.SDL_FRect {
            .x= x_pos,
            .y= y_pos,
            .w = @as(f32, @floatFromInt(size.w)),
            .h = @as(f32, @floatFromInt(size.h)),
        };
    }
    
    return slice;
}


pub fn deinit(self: *Atlas) !void {
    self.arena.deinit();
}



const expect = std.testing.expect;


test "init test" {
    var window:  *sdl.SDL_Window = null;
    var renderer:*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Starting game", 800, 600, sdl.SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        sdl.SDL_Log("Window / Renderer creation failed: %s", sdl.SDL_GetError());
        return error.SDLError;
    }
    

    const good_atlas: Atlas = .init(
        renderer,
        "texture/mock.png",
        std.heap.page_allocator
    );
    try expect(good_atlas);


    const bad_atlas: Atlas = .init();
    try expect(bad_atlas == error.SDLError);
}
