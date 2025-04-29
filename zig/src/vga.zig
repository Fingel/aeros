const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const ConsoleColors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

fn vgaEntryColor(fg: ConsoleColors, bg: ConsoleColors) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

fn vgaEntry(unsigned_char: u8, new_color: u8) u16 {
    const c: u16 = new_color;
    return unsigned_char | (c << 8);
}

pub const VgaDisplay = struct {
    column: usize = 0,
    color: u8 = vgaEntryColor(ConsoleColors.LightGreen, ConsoleColors.Black),
    buffer: [*]volatile u16 = @ptrFromInt(0xB8000),

    pub fn initialize(self: *VgaDisplay) void {
        self.clear();
    }

    pub fn clear(self: *VgaDisplay) void {
        @memset(self.buffer[0..VGA_SIZE], vgaEntry(' ', self.color));
    }

    fn putCharAt(self: *VgaDisplay, c: u8, new_color: u8) void {
        const index = (VGA_HEIGHT - 1) * VGA_WIDTH + self.column;
        self.buffer[index] = vgaEntry(c, new_color);
    }

    fn putChar(self: *VgaDisplay, c: u8) void {
        if (c == '\n') {
            self.newLine();
        } else {
            if (self.column == VGA_WIDTH) {
                self.newLine();
            }
            self.putCharAt(c, self.color);
            self.column += 1;
        }
    }

    fn newLine(self: *VgaDisplay) void {
        for (1..VGA_HEIGHT) |row| {
            for (0..VGA_WIDTH) |col| {
                const char = self.buffer[row * VGA_WIDTH + col];
                self.buffer[(row - 1) * VGA_WIDTH + col] = char;
            }
        }
        self.clearRow(VGA_HEIGHT - 1);
        self.column = 0;
    }

    fn clearRow(self: *VgaDisplay, row: usize) void {
        const index = row * VGA_WIDTH;
        @memset(self.buffer[index .. index + VGA_WIDTH], vgaEntry(' ', self.color));
    }

    pub fn setColor(self: *VgaDisplay, fg: ConsoleColors, bg: ConsoleColors) void {
        self.color = vgaEntryColor(fg, bg);
    }

    pub fn puts(self: *VgaDisplay, data: []const u8) void {
        for (data) |c| {
            self.putChar(c);
        }
    }
};
