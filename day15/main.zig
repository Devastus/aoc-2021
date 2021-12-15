const std = @import("std");
const math = std.math;

const data = @embedFile("input.txt");
const STEPS = std.math.maxInt(i32);
// const STEPS = 1000;

const Node = struct {
    height: u16 = 9,
    on_path: bool = false,
};

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,

    fn equal(self: *const Point, other: *const Point) bool {
        return self.x == other.x and self.y == other.y;
    }

    fn neighbours(self: *Point) [4]Point {
        return [4]Point{
            Point{ .x = self.x, .y = self.y - 1 },
            Point{ .x = self.x + 1, .y = self.y },
            Point{ .x = self.x, .y = self.y + 1 },
            Point{ .x = self.x - 1, .y = self.y },
        };
    }

    fn distance(self: *const Point, other: *Point) i32 {
        return abs(self.x - other.x) + abs(self.y - other.y);
    }
};

const PathNode = struct {
    point: Point = Point{},
    f: i32 = 0,
    parent: ?*PathNode = null,
};

const Map = struct {
    nodes: [16384]Node,
    len: usize,
    w: usize,
    h: usize,

    fn inBounds(self: *Map, point: Point) bool {
        return point.x >= 0 and point.x < self.w and point.y >= 0 and point.y < self.h;
    }

    fn getNode(self: *Map, point: Point) *Node {
        return &self.nodes[@intCast(usize, point.x) + (@intCast(usize, point.y) * self.w)];
    }

    fn getNodeBounded(self: *Map, point: Point) ?*Node {
        if (!inBounds(self, point)) return null;
        return &self.nodes[@intCast(usize, point.x) + (@intCast(usize, point.y) * self.w)];
    }
};

inline fn collectMap() Map {
    var map = Map{
        .nodes = [_]Node{Node{}} ** 16384,
        .len = 0,
        .w = 0,
        .h = 0,
    };
    var line_iter = std.mem.split(data, "\n");
    while(line_iter.next()) |line| {
        if (line.len > 0) {
            map.w = line.len;
            map.h += 1;
            for(line) |c| {
                map.nodes[map.len].height = c - '0';
                map.len += 1;
            }
        }
    }
    return map;
}

inline fn find(arr: *std.ArrayListUnmanaged(*Cell), p: *const Cell) ?*const Cell {
    for(arr.*.items) |it| {
        if (it.*.point.x == p.*.point.x and it.*.point.y == p.*.point.y) return it;
    }
    return null;
}

inline fn abs(a: i32) i32 {
    return (math.absInt(a) catch unreachable);
}

fn neighbours(map: *Map, q: *Cell) [4]?Cell {
    var i: usize = 0;
    var result = [_]?Cell{null} ** 4;
    var dirs = directions(q.*.point.x, q.*.point.y);
    while(i < 4) : (i += 1) {
        var point = dirs[i];
        if (q.parent) |p| {
            if (eqlPoint(p.point, point)) continue;
        }
        if (in_bounds(point.x, point.y, map.*.w, map.*.h)) {
            result[i] = Cell{
                .node = &map.*.nodes[i_xy(point.x, point.y, map.*.w)],
                .point = point,
                .parent = q
            };
        }
    }
    return result;
}

inline fn heuristic(f: i32, h: i32, p: *const Point, start: *Point, goal: *Point) i32 {
    return f + h; //Dijkstra
    // return f + h + p.distance(start) + p.distance(goal); // A*
}

fn compareF(a: *PathNode, b: *PathNode) std.math.Order {
    return std.math.order(a.f, b.f);
}

const EvalNode = struct {
    f: i32,
    closed: bool,
};

fn path02(alloc: *std.mem.Allocator, map: *Map, start: *Point, goal: *Point) !usize {
    var open = std.PriorityQueue(*PathNode).init(alloc, compareF);
    var evalNodes = std.AutoHashMap(Point, EvalNode).init(alloc);
    var begin = PathNode{ .point = start.* };
    try open.add(&begin);

    var end = eval: {
        var step: i32 = 0;
        while (open.len > 0 and step < STEPS) {
            var q = open.remove();
            // std.debug.print("{any}, F{d}\n", .{q.point, q.f});

            for (q.point.neighbours()) |p| {
                if (p.equal(goal)) {
                    break :eval PathNode{.point = p, .parent = q};
                }
                if (q.parent) |parent| {
                    if (p.equal(&parent.point)) continue;
                }

                if (map.getNodeBounded(p)) |n| {
                    var f = heuristic(q.f, n.height, &p, start, goal);

                    if (!evalNodes.contains(p)) {
                        try evalNodes.put(p, .{.f = f, .closed = false});
                    } else {
                        var ptr = evalNodes.getPtr(p).?;
                        if (ptr.f <= f) continue;

                        if (!ptr.closed) {
                            ptr.f = f;
                        }
                    }

                    var np = try alloc.create(PathNode);
                    np.point = p;
                    np.f = f;
                    np.parent = q;
                    // std.debug.print("    -> {any}, F{d}\n", .{np.point, np.f});
                    try open.add(np);
                }
            }

            if (!evalNodes.contains(q.point)) {
                try evalNodes.put(q.point, .{.f = q.f, .closed = true});
            } else {
                evalNodes.getPtr(q.point).?.closed = true;
            }

            step += 1;
        }
        std.debug.print("EVERYTHING'S FUCKED\n", .{});
        break :eval begin;
    };


    var total_risk: usize = 0;
    var cur: ?*PathNode = &end;
    while(cur) |p| {
        std.debug.print("{any}\n", .{ p });
        var n = map.getNode(p.point);
        total_risk += n.height;
        n.on_path = true;
        cur = p.parent;
    }
    total_risk -= map.nodes[0].height;
    return total_risk;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var alloc = &arena.allocator;
    defer arena.deinit();

    var map = collectMap();

    var start = Point{};
    var goal = Point{.x = @intCast(i32, map.w - 1), .y = @intCast(i32, map.h - 1)};
    var total_risk = try path02(alloc, &map, &start, &goal);

    var stdout = std.io.getStdOut();
    var i: usize = 0;
    var len = map.w * map.h;
    while(i < len) : (i += 1) {
        if (i % map.w == 0)
            std.debug.print("\n", .{});
        if (map.nodes[i].on_path) {
            std.debug.print("\x1b[31;1m{d}\x1b[0m ", .{map.nodes[i].height});
        } else {
            std.debug.print("{d} ", .{map.nodes[i].height});
        }
    }
    std.debug.print("\nTotal risk: {d}\n", .{total_risk});
}
