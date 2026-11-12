const VTable = struct { update: *const fn (*anyopaque, f32) void };

const UpdatableObject = @This();

ref: *anyopaque,
vTable: *const VTable,

pub fn init(ptr: anytype) UpdatableObject {
    const T = @TypeOf(ptr);

    const Bridge = struct {
        fn update(ctx: *anyopaque, delta_time: f32) void {
            const self: T = @ptrCast(@alignCast(ctx));
            self.update(delta_time);
        }
    };

    return .{ .ref = ptr, .vTable = &.{
        .update = Bridge.update,
    } };
}

pub fn update(self: UpdatableObject, delta_time: f32) void {
    self.vTable.update(self.ref, delta_time);
}
