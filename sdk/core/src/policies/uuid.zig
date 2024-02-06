//this code is borrowed from  the PR #18494
//which is implemented by https://github.com/jonathanmarvens
//since uuid is not yet available in the standard library

const std = @import("std");

const uuid = @This();

const uuid_hex_table: [256]*const [2:0]u8 = .{
    "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0a", "0b", "0c", "0d", "0e", "0f",
    "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1a", "1b", "1c", "1d", "1e", "1f",
    "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2a", "2b", "2c", "2d", "2e", "2f",
    "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3a", "3b", "3c", "3d", "3e", "3f",
    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4a", "4b", "4c", "4d", "4e", "4f",
    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5a", "5b", "5c", "5d", "5e", "5f",
    "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "6a", "6b", "6c", "6d", "6e", "6f",
    "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "7a", "7b", "7c", "7d", "7e", "7f",
    "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8a", "8b", "8c", "8d", "8e", "8f",
    "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9a", "9b", "9c", "9d", "9e", "9f",
    "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "aa", "ab", "ac", "ad", "ae", "af",
    "b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9", "ba", "bb", "bc", "bd", "be", "bf",
    "c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "ca", "cb", "cc", "cd", "ce", "cf",
    "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "da", "db", "dc", "dd", "de", "df",
    "e0", "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "e9", "ea", "eb", "ec", "ed", "ee", "ef",
    "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "fa", "fb", "fc", "fd", "fe", "ff",
};

pub fn docId(buf: *[16:0]u8) void {
    var rand_bytes: [16]u8 = undefined;
    const r = std.crypto.random;
    r.bytes(&rand_bytes);
    @memcpy(buf[0..2], uuid_hex_table[rand_bytes[0]]);
    @memcpy(buf[2..4], uuid_hex_table[rand_bytes[1]]);
    @memcpy(buf[4..6], uuid_hex_table[rand_bytes[2]]);
    @memcpy(buf[6..8], uuid_hex_table[rand_bytes[3]]);
    @memcpy(buf[8..10], uuid_hex_table[rand_bytes[4]]);
    @memcpy(buf[10..12], uuid_hex_table[rand_bytes[5]]);
    @memcpy(buf[12..14], uuid_hex_table[(rand_bytes[6] & 0x0f) | 0x40]);
    @memcpy(buf[14..16], uuid_hex_table[rand_bytes[7]]);
}

pub fn v4(buf: *[36:0]u8) void {
    var rand_bytes: [16]u8 = undefined;
    const r = std.crypto.random;
    r.bytes(&rand_bytes);
    @memcpy(buf[0..2], uuid_hex_table[rand_bytes[0]]);
    @memcpy(buf[2..4], uuid_hex_table[rand_bytes[1]]);
    @memcpy(buf[4..6], uuid_hex_table[rand_bytes[2]]);
    @memcpy(buf[6..8], uuid_hex_table[rand_bytes[3]]);
    buf[8] = '-';
    @memcpy(buf[9..11], uuid_hex_table[rand_bytes[4]]);
    @memcpy(buf[11..13], uuid_hex_table[rand_bytes[5]]);
    buf[13] = '-';
    @memcpy(buf[14..16], uuid_hex_table[(rand_bytes[6] & 0x0f) | 0x40]);
    @memcpy(buf[16..18], uuid_hex_table[rand_bytes[7]]);
    buf[18] = '-';
    @memcpy(buf[19..21], uuid_hex_table[(rand_bytes[8] & 0x3f) | 0x80]);
    @memcpy(buf[21..23], uuid_hex_table[rand_bytes[9]]);
    buf[23] = '-';
    @memcpy(buf[24..26], uuid_hex_table[rand_bytes[10]]);
    @memcpy(buf[26..28], uuid_hex_table[rand_bytes[11]]);
    @memcpy(buf[28..30], uuid_hex_table[rand_bytes[12]]);
    @memcpy(buf[30..32], uuid_hex_table[rand_bytes[13]]);
    @memcpy(buf[32..34], uuid_hex_table[rand_bytes[14]]);
    @memcpy(buf[34..36], uuid_hex_table[rand_bytes[15]]);
}

test "guid" {
    var buf: [16:0]u8 = undefined;
    var buf1: [16:0]u8 = undefined;

    docId(&buf);
    docId(&buf1);
    std.debug.print("\n{s}\n{s}\n", .{ buf, buf1 });
}
