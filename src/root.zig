const std = @import("std");
const zigx_nuhu_dev = @import("zigx_nuhu_dev");

const HASHNODE_GQL_URL = "https://gql.hashnode.com";
const HASHNODE_API_KEY = "YOUR_HASHNODE_API_KEY";
const CACHE_TTL_MS: i64 = 3_600_000; // 1 hour

// Simple in-memory cache with persistent allocator
const Cache = struct {
    allocator: std.mem.Allocator,
    data: ?[]const u8 = null,
    cached_at: i64 = 0,

    fn isValid(self: *const Cache) bool {
        if (self.data == null) return false;
        const now = std.time.milliTimestamp();
        return (now - self.cached_at) < CACHE_TTL_MS;
    }

    fn update(self: *Cache, data: []const u8) !void {
        // Free old cached data if exists
        if (self.data) |old_data| {
            self.allocator.free(old_data);
        }
        // Duplicate the data so it persists
        self.data = try self.allocator.dupe(u8, data);
        self.cached_at = std.time.milliTimestamp();
    }
};

var cache_gpa = std.heap.GeneralPurposeAllocator(.{}){};
var posts_cache: Cache = .{ .allocator = cache_gpa.allocator() };

const GetPostError = error{ FailedToFetchPosts, FailedToParsePosts, OutOfMemory };

pub fn getPosts(allocator: std.mem.Allocator) GetPostError![]Post {
    // Return cached data if valid
    if (posts_cache.isValid()) {
        return parsePostsFromJson(allocator, posts_cache.data.?) catch |err| {
            std.log.err("Failed to parse cached posts: {any}", .{err});
            return error.FailedToParsePosts;
        };
    }

    // Fetch fresh posts from Hashnode API
    var client = std.http.Client{ .allocator = allocator };
    const get_posts_query = @embedFile("queries/get_posts.gql");
    defer client.deinit();

    var aw = std.Io.Writer.Allocating.init(allocator);

    _ = client.fetch(.{
        .method = .POST,
        .location = .{ .url = HASHNODE_GQL_URL },
        .headers = std.http.Client.Request.Headers{
            .authorization = .{ .override = HASHNODE_API_KEY },
            .content_type = .{ .override = "application/json" },
        },
        .payload = try std.json.Stringify.valueAlloc(allocator, .{
            .query = get_posts_query,
        }, .{}),

        .response_writer = &aw.writer,
    }) catch |err| {
        std.log.err("Failed to fetch posts: {any}", .{err});
        return error.FailedToFetchPosts;
    };

    const response_text = aw.written();

    // Parse first to ensure it's valid before caching
    const posts = parsePostsFromJson(allocator, response_text) catch |err| {
        std.log.err("Failed to parse fetched posts: {any}", .{err});
        return error.FailedToParsePosts;
    };

    // Cache the response for future requests
    posts_cache.update(response_text) catch |err| {
        std.log.warn("Failed to cache posts: {any}", .{err});
        // Continue anyway, we have the parsed posts
    };

    return posts;
}

fn parsePostsFromJson(allocator: std.mem.Allocator, json_text: []const u8) ![]Post {
    const parsed = try std.json.parseFromSlice(HashnodeResponse, allocator, json_text, .{});
    // defer parsed.deinit();

    const parsed_value: HashnodeResponse = parsed.value;
    const post_edges = parsed_value.data.publication.posts.edges;
    const posts = try allocator.alloc(Post, post_edges.len);

    for (posts, 0..) |*post_node, i| {
        const post = post_edges[i].node;
        post_node.* = .{
            .title = post.title,
            .brief = post.brief,
            .url = post.url,
        };
    }

    return posts;
}

pub const Post = struct {
    title: []const u8,
    brief: []const u8,
    url: []const u8,
};

pub const HashnodeResponse = struct {
    data: struct {
        publication: struct {
            isTeam: bool,
            title: []const u8,
            posts: struct {
                edges: []struct {
                    node: struct {
                        id: []const u8,
                        coverImage: ?struct {
                            url: []const u8,
                        },
                        publishedAt: []const u8,
                        readTimeInMinutes: u32,
                        slug: []const u8,
                        subtitle: ?[]const u8,
                        views: u32,
                        title: []const u8,
                        brief: []const u8,
                        url: []const u8,
                        author: struct {
                            name: []const u8,
                        },
                    },
                },
            },
        },
    },
};
