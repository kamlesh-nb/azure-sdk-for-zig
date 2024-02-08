const std = @import("std");
 
 pub const Item = struct {
    OrderQty: i32,
    ProductId: i32,
    UnitPrice: f64,
    LineTotal: f64,
};

pub const SaleOrder = struct {
    id: []const u8 = undefined,
    PoNumber: []const u8 = undefined,
    OrderDate: []const u8 = undefined,
    ShippedDate: []const u8 = undefined,
    AccountNumber: []const u8 = undefined,
    RegionId: []const u8 = undefined,
    SubTotal: f64 = undefined,
    TaxAmount: f64 = undefined,
    Freight: f64 = undefined,
    TotalDue: f64 = undefined,
    Items: []Item = undefined,
    _rid: []const u8 = undefined,
    _self: []const u8 = undefined,
    _etag: []const u8 = undefined,
    _ts: u64 = undefined,
    _attachments: []const u8 = undefined,
};

pub const SaleOrders = struct {
    _rid: []const u8 = undefined,
    Documents: []SaleOrder = undefined,
    _count: u64 = undefined,
};