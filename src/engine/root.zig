const std = @import("std");
const sdl = @import("sdl");
const helper = @import("sdl_helper.zig");

pub const Engine = @This();

window: *sdl.SDL_Window,
renderer: *sdl.SDL_Renderer,
running: bool,

player: Player = .init,

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
            sdl.SDL_EVENT_KEY_UP => {
                const kb_event = event.key;
                self.handleKeyUp(kb_event.key);
            },
            sdl.SDL_EVENT_KEY_DOWN => {
                const kb_event = event.key;
                self.handleKeyDown(kb_event.key);
            },
            else => {},
        }
    }
}

fn handleKeyDown(self: *Engine, key: c_uint) void {
    switch (key) {
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
        else => {},
    }
}

fn handleKeyUp(self: *Engine, key: c_uint) void {
    switch (key) {
        sdl.SDLK_A, sdl.SDLK_D => {
            self.player.direction.x = 0;
        },
        sdl.SDLK_W, sdl.SDLK_S => {
            self.player.direction.y = 0;
        },
        else => {},
    }
}

fn update(self: *Engine, delta_time: f32) void {
    // Game logic
    try self.player.update(delta_time);
}

pub fn init() !Engine {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        sdl.SDL_Log("Init failed: %s", sdl.SDL_GetError());
        return error.InternalError;
    }
    errdefer sdl.SDL_Quit();

    var window: ?*sdl.SDL_Window = null;
    var renderer: ?*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Starting game", 800, 600, sdl.SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        sdl.SDL_Log("Window / Renderer creation failed: %s", sdl.SDL_GetError());
        return error.InternalError;
    }

    const win = window.?;
    const ren = renderer.?;

    return Engine{
        .window = win,
        .renderer = ren,
        .running = true,
    };
}

const Player = struct {
    bounds: sdl.SDL_FRect = .{
        .x = 0,
        .y = 0,
        .h = 64,
        .w = 32,
    },
    speed: f32 = 300.0,
    direction: sdl.SDL_FPoint = .{
        .x = 0,
        .y = 0,
    },

    const init: Player = .{};

    fn update(self: *Player, delta_time: f32) !void {
        self.bounds.x += delta_time * self.speed * self.direction.x;
        self.bounds.y += delta_time * self.speed * self.direction.y;
    }
    fn render(self: *Player, renderer: *sdl.SDL_Renderer) !void {
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &self.bounds);
    }
};
