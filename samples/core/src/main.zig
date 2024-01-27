const std = @import("std");
const time = std.time;
const epoch = std.time.epoch;

fn isoformatTimestamp(epoch_ms: i64, buf: []u8) ![]const u8 {
    const seconds = @divTrunc(epoch_ms, 1000);
    const ms = epoch_ms - (seconds * 1000);
    const day_seconds: epoch.DaySeconds = .{
        .secs = @as(u17, @intCast(@mod(seconds, time.s_per_day))),
    };
    const epoch_day: epoch.EpochDay = .{
        .day = @as(u47, @intCast(@divTrunc(seconds, epoch.secs_per_day))),
    };
    const year_and_day = epoch_day.calculateYearDay();
    const month_and_day = year_and_day.calculateMonthDay();

    const res = try std.fmt.bufPrint(
        buf,
        "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3}Z",
        .{
            year_and_day.year,
            month_and_day.month.numeric(),
            month_and_day.day_index + 1,
            day_seconds.getHoursIntoDay(),
            day_seconds.getMinutesIntoHour(),
            day_seconds.getSecondsIntoMinute(),
            @as(u10, @intCast(ms)),
        },
    );
    return res[0..res.len];
}

pub fn main() !void {
    const now = time.milliTimestamp();
    var buf: [32]u8 = undefined;
    const iso = try isoformatTimestamp(now, &buf);
    std.debug.print("\niso8601 TS: \n{s}\n", .{iso});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
