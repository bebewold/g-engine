


// concise way to cast int to float
pub fn FfromI(T: type, x: anytype) T {
    return @as(T, @floatFromInt(x));
}
