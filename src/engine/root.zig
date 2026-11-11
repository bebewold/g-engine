const std = @import("std");
const sdl = @import("sdl");

const helper = @import("sdl_helper.zig");
const utils = @import("utils.zig");
const atlas_lib = @import("atlas.zig");

pub const Engine = @This();

window: *sdl.SDL_Window,
renderer: *sdl.SDL_Renderer,
player: Player,
running: bool,

pub fn run(self: *Engine) !void {
    const target_fps: u32 = 60;
    const FRAME_TIME_TARGET: u64 = 1000 / target_fps;
    var frame_start: u64 = undefined;
    var delta_time: f32 = 0.0;

    while (self.running) {
        frame_start = sdl.SDL_GetTicks();

        self.handleEvents();
        if (!self.running) break;

        // Game logic update
        self.update(delta_time);

        // Apply changes to screen
        try helper.SDLCheck(
            sdl.SDL_SetRenderDrawColor(self.renderer, 30, 30, 60, 255),
            "error setting draw color",
        );
        try helper.SDLCheck(
            sdl.SDL_RenderClear(self.renderer),
            "error clearing the rendering buffer",
        );

        self.player.update(delta_time);
        try self.player.render(self.renderer);

        try helper.SDLCheck(
            sdl.SDL_RenderPresent(self.renderer),
            "error presenting the render buffer",
        );

        // Frame timing & delay calculation
        const frame_time: u32 = @intCast(sdl.SDL_GetTicks() - frame_start);

        if (frame_time < FRAME_TIME_TARGET) {
            sdl.SDL_Delay(@intCast(FRAME_TIME_TARGET - frame_time));
        }
        delta_time = @as(f32, @floatFromInt(sdl.SDL_GetTicks() - frame_start)) / 1000;
    }
}

pub fn shutdown(self: *Engine) void {
    sdl.SDL_DestroyRenderer(self.renderer);
    sdl.SDL_DestroyWindow(self.window);
    sdl.SDL_Quit();
}

fn handleEvents(self: *Engine) void {
    var event: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&event)) {
        switch (event.type) {
            sdl.SDL_EVENT_QUIT => {
                self.running = false;
                return;
            },
            sdl.SDL_EVENT_KEY_DOWN => {
                switch (event.key.key) {
                    sdl.SDLK_ESCAPE => {
                        self.running = false;
                        return;
                    },
                    sdl.SDLK_A => {
                        self.player.direction.x = -1;
                    },
                    sdl.SDLK_D => {
                        self.player.direction.x = 1;
                    },
                    sdl.SDLK_W => {
                        self.player.direction.y = -1;
                    },
                    sdl.SDLK_S => {
                        self.player.direction.y = 1;
                    },
                    else => { // this is assumed as nothing
                    },
                }
            },

            sdl.SDL_EVENT_KEY_UP => {
                switch (event.key.key) {
                    sdl.SDLK_A, sdl.SDLK_D => {
                        self.player.direction.x = 0;
                    },
                    sdl.SDLK_W, sdl.SDLK_S => {
                        self.player.direction.y = 0;
                    },
                    else => {},
                }
            },
            else => {},
        }
    }
}

fn update(self: *Engine, delta_time: f32) void {
    // Game logic
    self.player.update(delta_time);
}

pub fn init(allocator: std.mem.Allocator) !Engine {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        sdl.SDL_Log("Init failed: %s", sdl.SDL_GetError());
        return error.SDLError;
    }
    errdefer sdl.SDL_Quit();

    var window: ?*sdl.SDL_Window = null;
    var renderer: ?*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Starting game", 800, 600, sdl.SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        sdl.SDL_Log("Window / Renderer creation failed: %s", sdl.SDL_GetError());
        return error.SDLError;
    }

    // creates a texture
    const atlas: atlas_lib.Self = try .init(
        renderer.?,
        "./texture/sprite_sheet.png",
    );
    const player = try Player.init(&atlas, allocator);

    const win = window.?;
    const ren = renderer.?;

    return Engine{ .window = win, .renderer = ren, .running = true, .player = player };
}

const State = enum(u8) {
    idle,
    run,
};

// ----------------------------------------
//  Description:
//  playable character
// ----------------------------------------
const Player = struct {
    texture: *const sdl.SDL_Texture,
    bounds: sdl.SDL_FRect = .{
        .x = 0,
        .y = 0,
        .h = 64,
        .w = 32,
    },

    timer: f32 = 0,
    frame_duration: f32 = 0.15,

    state: State = .idle,
    frame_index: usize = 0,
    animations: [2][]sdl.SDL_FRect,

    direction: sdl.SDL_FPoint = .{
        .x = 0,
        .y = 0,
    },
    speed: f32 = 100.0,

    pub fn init(
        atlas: *const atlas_lib.Self,
        allocator: std.mem.Allocator,
    ) !Player {
        const idle_animation = try atlas.slice(allocator, .{ .x = 1, .y = 1 }, .{ .w = 16, .h = 16 }, 1, 1);
        const run_animation = try atlas.slice(allocator, .{ .x = 1, .y = 1 }, .{ .w = 16, .h = 16 }, 4, 1);

        return Player{
            .texture = atlas.ref_texture(),
            .animations = .{ idle_animation, run_animation },
        };
    }

    fn update(self: *Player, delta_time: f32) void {
        const is_moving = (self.direction.x != 0 or self.direction.y != 0);
        const new_state: State = if (is_moving) .run else .idle;

        if (self.state != new_state) {
            self.state = new_state;
            self.frame_index = 0;
        }

        self.timer += delta_time;
        if (self.timer >= self.frame_duration) {
            self.timer = 0.0;

            const animation = self.animations[@backingInt(self.state)];
            // prevent overflowing
            self.frame_index = (self.frame_index + 1) % animation.len;
        }

        self.bounds.x += delta_time * self.speed * self.direction.x;
        self.bounds.y += delta_time * self.speed * self.direction.y;
    }

    fn render(self: *Player, renderer: *sdl.SDL_Renderer) !void {
        const state_index = @backingInt(self.state);
        const frame = switch (self.state) {
            .idle => self.animations[state_index],
            .run => self.animations[state_index],
        };

        try helper.SDLCheck(
            sdl.SDL_RenderTexture(renderer, @constCast(self.texture), &frame[self.frame_index], &self.bounds),
            "error setting draw color",
        );
    }
};
