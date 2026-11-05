const std = @import("std");
const sdl = @import("sdl");

pub const Engine = @This();

window: *sdl.SDL_Window,
renderer: *sdl.SDL_Renderer,
running: bool,

pub fn run(self: *Engine) void {
    const target_fps: u32 = 60;
    const FRAME_TIME_TARGET: u64 = 1000 / target_fps;
    var frame_start: u64 = undefined;
    var delta_time: f64 = 0.0;

    while (self.running) {
        frame_start = sdl.SDL_GetTicks();

        if (!self.handleEvents()) break;

        // Game logic update
        self.update(delta_time);

        // Apply changes to screen
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, 30, 30, 60, 255);
        _ = sdl.SDL_RenderClear(self.renderer);
        _ = sdl.SDL_RenderPresent(self.renderer);

        // Frame timing & delay calculation
        const frame_time: u32 = @intCast(sdl.SDL_GetTicks() - frame_start);

        if (frame_time < FRAME_TIME_TARGET) {
            sdl.SDL_Delay(@intCast(FRAME_TIME_TARGET - frame_time));
        }
        delta_time = @as(f64, @floatFromInt(sdl.SDL_GetTicks() - frame_start)) / 1000;
    }
}

pub fn shutdown(self: *Engine) void {
    sdl.SDL_DestroyRenderer(self.renderer);
    sdl.SDL_DestroyWindow(self.window);
    sdl.SDL_Quit();
}

fn handleEvents(self: *Engine) bool {
    var event: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&event)) {
        switch (event.type) {
            sdl.SDL_EVENT_QUIT => {
                self.running = false;
                return false;
            },
            sdl.SDL_EVENT_KEY_DOWN => {
                if (event.key.key == sdl.SDLK_ESCAPE) {
                    self.running = false;
                    return false;
                }
            },
            else => {},
        }
    }

    return true;
}

fn update(self: *Engine, delta_time: f64) void {
    _ = self;
    _ = delta_time;
    // Game logic
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
