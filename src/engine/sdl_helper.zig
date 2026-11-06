const sdl = @import("sdl");

pub fn SDLCheck(ok: bool, err_msg: [*:0]const u8) !void {
    if (!ok) {
        _ = sdl.SDL_SetError("%s: %s", err_msg, sdl.SDL_GetError());
        return error.SDLError;
    }
}
