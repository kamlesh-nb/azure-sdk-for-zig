const std = @import("std");
const core = @import("azcore");

const Method = core.Method;
const Status = core.Status;


pub const CosmosErrors = error{
    BadRequest,
    EntityTooLarge,
    ContainerNotFound,
    ItemNotFound,
    ItemNotModified,
    ItemAlreadyReplaced,
    DatabaseNotFound,
    DatabaseAlreadyExists,
    ContainterAlreadyExists,
    ItemWithPartitionKeyAlreadyExists,
    PartitionKeyMismatch,
    PreconditionFailed,
    RequestRateTooLarge,
    TooManyRequests,
    Unauthorized,
    Forbidden,
    UnknownError,
};

pub fn hasError(method: Method, status: Status) bool {
    switch (method) {
        .post, .patch => {
            switch (status) {
                .ok, .created, .no_content, .accepted => return false,
                else => return true,
            }
        },
        .put,
        .get,
        => {
            switch (status) {
                .ok => return false,
                else => return true,
            }
        },
        .delete => {
            switch (status) {
                .ok, .no_content, .accepted => return false,
                else => return true,
            }
        },
        else => return true,
    }
}
