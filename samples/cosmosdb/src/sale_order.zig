const std = @import("std");

pub const Item = struct {
    OrderQty: i32,
    ProductId: i32,
    UnitPrice: f64,
    LineTotal: f64,
};

pub const SaleOrder = struct {
    id: []const u8,
    PoNumber: []const u8,
    OrderDate: []const u8,
    ShippedDate: []const u8,
    AccountNumber: []const u8,
    RegionId: []const u8,
    SubTotal: f64,
    TaxAmount: f64,
    Freight: f64,
    TotalDue: f64,
    Items: []Item,
    _rid: []const u8 = undefined,
    _self: []const u8 = undefined,
    _etag: []const u8 = undefined,
    _ts: u64 = undefined,
    _attachments: []const u8 = undefined,
};

pub const SaleOrders = struct {
    _rid: []const u8,
    Documents: []SaleOrder,
    _count: u64,
};
