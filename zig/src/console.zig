const fmt = @import("std").fmt;
const Writer = @import("std").io.Writer;
const vga = @import("vga.zig");

var display = vga.VgaDisplay{};

pub fn initialize() void {
    display.initialize();
}

fn callback(_: void, string: []const u8) error{}!usize {
    display.puts(string);
    return string.len;
}

const writer = Writer(void, error{}, callback){ .context = {} };

pub fn printf(comptime format: []const u8, args: anytype) void {
    fmt.format(writer, format, args) catch unreachable;
}
