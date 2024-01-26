const std = @import("std");

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
