const std = @import("std");
const Policy = @import("policies.zig");
const policies = std.SinglyLinkedList(Policy.Policy);

const Pipeline = @This();

pipeline: policies,

pub fn new() Pipeline {
    var pl = Pipeline{.pipeline = .{}, };

    pl.pipeline.prepend();

    return pl;
}
