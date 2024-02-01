const std = @import("std");
const assert = std.debug.assert;
const time = std.time;
const epoch = std.time.epoch;

pub const Weekday = enum(u3) {
    Monday = 1,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday,

    pub fn dayUpper(self: Weekday) []const u8 {
        switch (self) {
            .Monday => return "Mon",
            .Tuesday => return "Tue",
            .Wednesday => return "Wed",
            .Thursday => return "Thu",
            .Friday => return "Fri",
            .Saturday => return "Sat",
            .Sunday => return "Sun",
        }
    }

    pub fn dayLower(self: Weekday) []const u8 {
        switch (self) {
            .Monday => return "mon",
            .Tuesday => return "tue",
            .Wednesday => return "wed",
            .Thursday => return "thu",
            .Friday => return "fri",
            .Saturday => return "sat",
            .Sunday => return "sun",
        }
    }
};

pub const Month = enum(u4) {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December,

    pub fn monthUpper(self: Month) []const u8 {
        switch (self) {
            .January => return "Jan",
            .February => return "Feb",
            .March => return "Mar",
            .April => return "Apr",
            .May => return "May",
            .June => return "Jun",
            .July => return "Jul",
            .August => return "Aug",
            .September => return "Sep",
            .October => return "Oct",
            .November => return "Nov",
            .December => return "Dec",
        }
    }

    pub fn monthLower(self: Month) []const u8 {
        switch (self) {
            .January => return "jan",
            .February => return "feb",
            .March => return "mar",
            .April => return "apr",
            .May => return "may",
            .June => return "jun",
            .July => return "jul",
            .August => return "aug",
            .September => return "sep",
            .October => return "oct",
            .November => return "nov",
            .December => return "dec",
        }
    }
};

const IsoDate = @This();

day: u8 = 0,
month: u8 = 0,
year: u16 = 0,
weekday: Weekday = undefined,
monthName: Month = undefined,
hours: u6 = undefined,
minutes: u6 = undefined,
seconds: u6 = undefined,
miliseconds: u10 = undefined,

fn init(msepoch: i64) IsoDate {
    const seconds = @divTrunc(msepoch, 1000);
    const ms = msepoch - (seconds * 1000);

    const day_seconds: epoch.DaySeconds = .{
        .secs = @as(u17, @intCast(@mod(seconds, time.s_per_day))),
    };

    const epoch_day: epoch.EpochDay = .{
        .day = @as(u47, @intCast(@divTrunc(seconds, epoch.secs_per_day))),
    };
    const year_and_day = epoch_day.calculateYearDay();
    const month_and_day = year_and_day.calculateMonthDay();

    return IsoDate{
        .day = month_and_day.day_index + 1,
        .month = month_and_day.month.numeric(),
        .year = year_and_day.year,
        .monthName = @enumFromInt(month_and_day.month.numeric()),
        .weekday = dayOfWeek(.{
            .day = month_and_day.day_index + 1,
            .month = month_and_day.month.numeric(),
            .year = year_and_day.year,
        }),
        .hours = day_seconds.getHoursIntoDay(),
        .minutes = day_seconds.getMinutesIntoHour(),
        .seconds = day_seconds.getSecondsIntoMinute(),
        .miliseconds = @as(u10, @intCast(ms)),
    };
}

pub fn now() IsoDate {
    const msepoch = time.milliTimestamp();
    return init(msepoch);
}

const DAYS_IN_MONTH = [12]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
const DAYS_BEFORE_MONTH = [12]u16{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };

pub fn isLeapYear(year: u32) bool {
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0);
}

fn isLeapDay(year: u32, month: u32, day: u32) bool {
    return isLeapYear(year) and month == 2 and day == 29;
}

fn daysBeforeYear(year: u32) u32 {
    const y: u32 = year - 1;
    return y * 365 + @divFloor(y, 4) - @divFloor(y, 100) + @divFloor(y, 400);
}

fn daysInMonth(year: u32, month: u32) u8 {
    assert(1 <= month and month <= 12);
    if (month == 2 and isLeapYear(year)) return 29;
    return DAYS_IN_MONTH[month - 1];
}

fn daysBeforeMonth(year: u32, month: u32) u32 {
    assert(month >= 1 and month <= 12);
    var d = DAYS_BEFORE_MONTH[month - 1];
    if (month > 2 and isLeapYear(year)) d += 1;
    return d;
}

fn ymd2ord(year: u16, month: u8, day: u8) u32 {
    assert(month >= 1 and month <= 12);
    assert(day >= 1 and day <= daysInMonth(year, month));
    return daysBeforeYear(year) + daysBeforeMonth(year, month) + day;
}

fn toOrdinal(self: IsoDate) u32 {
    return ymd2ord(self.year, self.month, self.day);
}

fn dayOfWeek(self: IsoDate) Weekday {
    const dow: u3 = @intCast(self.toOrdinal() % 7);
    return @enumFromInt(if (dow == 0) 7 else dow);
}

pub fn addDays(days: i64) IsoDate {
    const daysms = days * 24 * 60 * 60 * 1000;
    const msepoch = time.milliTimestamp() + daysms;
    return init(msepoch);
}

pub fn minusDays(days: i64) IsoDate {
    const daysms = days * 24 * 60 * 60 * 1000;
    const msepoch = time.milliTimestamp() - daysms;
    return init(msepoch);
}

pub fn addWeeks(weeks: i64) IsoDate {
    const weeksms = weeks * 7 * 24 * 60 * 60 * 1000;
    const msepoch = time.milliTimestamp() + weeksms;
    return init(msepoch);
}

pub fn minusWeeks(weeks: i64) IsoDate {
    const weeksms = weeks * 7 * 24 * 60 * 60 * 1000;
    const msepoch = time.milliTimestamp() - weeksms;
    return init(msepoch);
}

pub fn isoDate(self: *IsoDate, buf: []u8) ![]const u8 {
    
    const res = try std.fmt.bufPrint(
        buf,
        "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3}Z",
        .{
            self.year,
            self.month,
            self.day,
            self.hours,
            self.minutes,
            self.seconds,
            self.miliseconds,
        },
    );
    return res[0..res.len];
}

pub fn httpDate(self: *IsoDate, buf: []u8) ![]const u8 {
     
    const res = try std.fmt.bufPrint(
        buf,
        "{s}, {d:0>2} {s} {d:0>4} {d:0>2}:{d:0>2}:{d:0>2}.{d:0>3} GMT",
        .{
            self.weekday.dayUpper(),
            self.day,
            self.monthName.monthUpper(),
            self.year,
            self.hours,
            self.minutes,
            self.seconds,
            self.miliseconds,
        },
    );

    return res[0..res.len];
}

//Sun, 29 Nov 2015 02:25:35.212 GMT
test "iosDate" {
    var date = IsoDate.now();
    var iso: [34]u8 = undefined;
    const resIso = try date.isoDate(&iso);
    std.debug.print("\nIso Date: {s}\n", .{resIso});
    var http: [34]u8 = undefined;
    const resHttp = try date.httpDate(&http);
    std.debug.print("Http Date: {s}\n", .{resHttp});
}

test "date" {
    var date = IsoDate.now();
    std.debug.print("\n\n{s}\n\n", .{date.monthName.monthUpper()});
}

test "addDays" {
    // var d = Date.now();
    var date = IsoDate.addDays(12);
    var iso: [34]u8 = undefined;
    const resIso = try date.isoDate(&iso);
    std.debug.print("\nIso Date: {s}\n", .{resIso});
    var http: [34]u8 = undefined;
    const resHttp = try date.httpDate(&http);
    std.debug.print("Http Date: {s}\n", .{resHttp});
}

test "minusDays" {
    // var d = Date.now();
    var date = IsoDate.minusDays(12);
    var iso: [34]u8 = undefined;
    const resIso = try date.isoDate(&iso);
    std.debug.print("\nIso Date: {s}\n", .{resIso});
    var http: [34]u8 = undefined;
    const resHttp = try date.httpDate(&http);
    std.debug.print("Http Date: {s}\n", .{resHttp});
}

test "addWeeks" {
    // var d = Date.now();
    var date = IsoDate.addWeeks(12);
    var iso: [34]u8 = undefined;
    const resIso = try date.isoDate(&iso);
    std.debug.print("\nIso Date: {s}\n", .{resIso});
    var http: [34]u8 = undefined;
    const resHttp = try date.httpDate(&http);
    std.debug.print("Http Date: {s}\n", .{resHttp});
}

test "minusWeeks" {
    // var d = Date.now();
    var date = IsoDate.minusWeeks(15);
    var iso: [34]u8 = undefined;
    const resIso = try date.isoDate(&iso);
    std.debug.print("\nIso Date: {s}\n", .{resIso});
    var http: [34]u8 = undefined;
    const resHttp = try date.httpDate(&http);
    std.debug.print("Http Date: {s}\n", .{resHttp});
}
