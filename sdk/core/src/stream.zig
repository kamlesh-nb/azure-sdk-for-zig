const std = @import("std");
const io = std.io;
const crypto = std.crypto;
const tls = @import("tls");

const assert = std.debug.assert;
const builtin = @import("builtin");
const posix = std.posix;

const native_os = builtin.os.tag;

const windows = std.os.windows;

const aio = @import("aio");
const coro = @import("coro");

pub const SkipBytesOptions = struct {
    buf_size: usize = 512,
};

pub const Stream = struct {
    handle: posix.socket_t,

    pub fn close(s: Stream) !void {
        try coro.io.single(.close_socket, .{ .socket = s.handle });
    }

    pub const ReadError = posix.ReadError || aio.Error ||
        error{ FastOpenAlreadyInProgress, TlsBadVersion, TlsUnexpectedMessage, TlsRecordOverflow, TlsDecryptError, TlsDecodeError, TlsBadRecordMac, TlsIllegalParameter, TlsCipherNoSpaceLeft, NetworkUnreachable } || error{ ConnectionRefused, ConnectionTimedOut, ConnectionResetByPeer, SystemResources, SocketNotConnected, Success, SocketNotBound, MessageTooBig, NetworkSubsystemFailed, OperationNotSupported, FileDescriptorNotASocket } || error{ InputOutput, AccessDenied, PermissionDenied, BrokenPipe, SystemResources, OperationAborted, LockViolation, WouldBlock, ConnectionResetByPeer, ProcessNotFound, NoDevice, Unexpected, OutOfMemory, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, IsDir, LockedMemoryLimitExceeded, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, Canceled, ConnectionRefused, Success, CompletionQueueOvercommitted, SubmissionQueueFull, UserResourceLimitReached, ThreadQuotaExceeded, SystemOutdated, Unsupported, TlsIllegalParameter, TlsRecordOverflow, TlsBadVersion, TlsUnexpectedMessage, TlsDecryptError, TlsDecodeError, TlsBadRecordMac, TlsCipherNoSpaceLeft } ||
        error{ NoSpaceLeft, DiskQuota, FileTooBig, InputOutput, DeviceBusy, InvalidArgument, AccessDenied, PermissionDenied, BrokenPipe, SystemResources, OperationAborted, NotOpenForWriting, LockViolation, WouldBlock, ConnectionResetByPeer, ProcessNotFound, NoDevice, MessageTooBig, Unexpected, OutOfMemory, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, IsDir, LockedMemoryLimitExceeded, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, Canceled, NetworkSubsystemFailed, OperationNotSupported, SocketNotBound, ConnectionRefused, Success, CompletionQueueOvercommitted, SubmissionQueueFull, UserResourceLimitReached, ThreadQuotaExceeded, SystemOutdated, Unsupported, TlsIllegalParameter, TlsRecordOverflow, TlsBadVersion, TlsUnexpectedMessage, TlsDecryptError, TlsDecodeError, TlsBadRecordMac, TlsCipherNoSpaceLeft };
    pub const WriteError = posix.WriteError || aio.Error || error{ FastOpenAlreadyInProgress, TlsCipherNoSpaceLeft, TlsUnexpectedMessage, NetworkUnreachable } || error{ ConnectionRefused, ConnectionTimedOut, ConnectionResetByPeer, SystemResources, SocketNotConnected, Success, SocketNotBound, MessageTooBig, NetworkSubsystemFailed, OperationNotSupported, FileDescriptorNotASocket } || error{ InputOutput, AccessDenied, PermissionDenied, BrokenPipe, SystemResources, OperationAborted, LockViolation, WouldBlock, ConnectionResetByPeer, ProcessNotFound, NoDevice, Unexpected, OutOfMemory, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, IsDir, LockedMemoryLimitExceeded, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, Canceled, ConnectionRefused, Success, CompletionQueueOvercommitted, SubmissionQueueFull, UserResourceLimitReached, ThreadQuotaExceeded, SystemOutdated, Unsupported, TlsIllegalParameter, TlsRecordOverflow, TlsBadVersion, TlsUnexpectedMessage, TlsDecryptError, TlsDecodeError, TlsBadRecordMac, TlsCipherNoSpaceLeft } || error{ NoSpaceLeft, DiskQuota, FileTooBig, InputOutput, DeviceBusy, InvalidArgument, AccessDenied, PermissionDenied, BrokenPipe, SystemResources, OperationAborted, NotOpenForWriting, LockViolation, WouldBlock, ConnectionResetByPeer, ProcessNotFound, NoDevice, MessageTooBig, Unexpected, OutOfMemory, ProcessFdQuotaExceeded, SystemFdQuotaExceeded, IsDir, LockedMemoryLimitExceeded, ConnectionTimedOut, NotOpenForReading, SocketNotConnected, Canceled, NetworkSubsystemFailed, OperationNotSupported, SocketNotBound, ConnectionRefused, Success, CompletionQueueOvercommitted, SubmissionQueueFull, UserResourceLimitReached, ThreadQuotaExceeded, SystemOutdated, Unsupported, TlsIllegalParameter, TlsRecordOverflow, TlsBadVersion, TlsUnexpectedMessage, TlsDecryptError, TlsDecodeError, TlsBadRecordMac, TlsCipherNoSpaceLeft };

    pub const Reader = io.Reader(Stream, ReadError, read);
    pub const Writer = io.Writer(Stream, WriteError, write);

    pub fn reader(self: Stream) Reader {
        return .{ .context = self };
    }

    pub fn writer(self: Stream) Writer {
        return .{ .context = self };
    }

    pub fn read(self: Stream, buffer: []u8) ReadError!usize {
        var len: usize = 0;
        try coro.io.single(.recv, .{ .socket = self.handle, .buffer = @constCast(buffer), .out_read = &len });
        return len;
    }

    // pub fn readv(self: Stream, iovecs: []const posix.iovec) ReadError!usize {
    //     if (native_os == .windows) {
    //         // TODO improve this to use ReadFileScatter
    //         if (iovecs.len == 0) return @as(usize, 0);
    //         const first = iovecs[0];
    //         return windows.ReadFile(self.handle, first.base[0..first.len], null);
    //     }

    //     return posix.readv(self.handle, iovecs);
    // }

    // pub fn readByte(self: Stream) anyerror!u8 {
    //     var result: [1]u8 = undefined;
    //     var len: usize = 0;
    //     try coro.io.single(.recv, .{ .socket = self.handle, .buffer = &result, .out_read = &len });
    //     if (len < 1) return error.EndOfStream;
    //     return result[0];
    // }

    // pub inline fn readInt(self: Stream, comptime T: type, endian: std.builtin.Endian) anyerror!T {
    //     const amt = @divExact(@typeInfo(T).int.bits, 8);
    //     var buffer: [amt]u8 = undefined;
    //     var len: usize = 0;

    //     try coro.io.single(.recv, .{ .socket = self.handle, .buffer = &buffer, .out_read = &len });

    //     return std.mem.readInt(T, &buffer, endian);
    // }

    pub fn readAll(s: Stream, buffer: []u8) anyerror!usize {
        return readAtLeast(s, buffer, buffer.len);
    }

    pub fn readAtLeast(s: Stream, buffer: []u8, len: usize) anyerror!usize {
        assert(len <= buffer.len);
        var index: usize = 0;
        while (index < len) {
            var amt: usize = 0;
            try coro.io.single(.recv, .{ .socket = s.handle, .buffer = buffer[index..], .out_read = &amt });

            if (amt == 0) break;
            index += amt;
        }
        return index;
    }

    // pub fn skipBytes(self: Stream, num_bytes: u64, comptime options: SkipBytesOptions) anyerror!void {
    //     var buf: [options.buf_size]u8 = undefined;
    //     var remaining = num_bytes;

    //     while (remaining > 0) {
    //         const amt = @min(remaining, options.buf_size);
    //         _ = try self.readAll(buf[0..amt]);
    //         remaining -= amt;
    //     }
    // }

    pub fn write(self: Stream, buffer: []const u8) WriteError!usize {
        var len: usize = 0;
        try coro.io.single(.send, .{ .socket = self.handle, .buffer = buffer, .offset = 0, .out_written = &len });
        return len;
    }

    pub fn writeAll(self: Stream, bytes: []const u8) !void {
        var index: usize = 0;
        while (index < bytes.len) {
            var len: usize = 0;
            try coro.io.single(.send, .{ .socket = self.handle, .buffer = bytes[index..], .out_written = &len });
            index += len;
        }
    }

    // pub fn writev(self: Stream, iovecs: []const posix.iovec_const) WriteError!usize {
    //     return posix.writev(self.handle, iovecs);
    // }

    // pub fn writevAll(self: Stream, iovecs: []posix.iovec_const) WriteError!void {
    //     if (iovecs.len == 0) return;

    //     var i: usize = 0;
    //     while (true) {
    //         var amt = try self.writev(iovecs[i..]);
    //         while (amt >= iovecs[i].len) {
    //             amt -= iovecs[i].len;
    //             i += 1;
    //             if (i >= iovecs.len) return;
    //         }
    //         iovecs[i].base += amt;
    //         iovecs[i].len -= amt;
    //     }
    // }
};
