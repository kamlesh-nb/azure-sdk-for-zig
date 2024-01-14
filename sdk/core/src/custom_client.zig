const std = @import("std");
const http = @import("http");
const Request = http.Request;
const Response = http.Response;

const CustomHttpClient = @This();
