const sdl = @import("sdl");

const VTable = struct {
    render: *const fn (*anyopaque, *sdl.SDL_Renderer) error{SDLError}!void,
};

const Renderable = @This();

ref: *anyopaque,
vTable: *const VTable,

pub fn init(ptr: anytype) Renderable {
    const T = @TypeOf(ptr);
    const Bridge = struct {
        pub fn render(ctx: *anyopaque, renderer: *sdl.SDL_Renderer) !void {
            const self: T = @ptrCast(@alignCast(ctx));
            try self.render(renderer);
        }
    };

    return .{ .ref = ptr, .vTable = &.{
        .render = Bridge.render,
    } };
}

pub fn render(self: Renderable, renderer: *sdl.SDL_Renderer) !void {
    try self.vTable.render(self.ref, renderer);
}
