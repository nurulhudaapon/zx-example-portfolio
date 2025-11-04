pub const routes = [_]zx.App.Meta.Route{
    .{
        .path = "/",
        .page = @import("./.zx/pages/page.zig").Page,
        .layout = @import("./.zx/pages/layout.zig").Layout,
        .routes = &.{
            .{
                .path = "/about",
                .page = @import("./.zx/pages/about/page.zig").Page,
            },
            .{
                .path = "/time",
                .page = @import("./.zx/pages/time/page.zig").Page,
            },
            .{
                .path = "/blog",
                .page = @import("./.zx/pages/blog/page.zig").Page,
            },
        },
    },
};

pub const meta = zx.App.Meta{
    .routes = &routes,
};

const zx = @import("zx");
