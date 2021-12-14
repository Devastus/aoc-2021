const std = @import("std");

const data = @embedFile("input.txt");
const STEPS = 40;
const BYTE_MASK: u16 = std.math.maxInt(u8);

fn convertPair(k_str: []const u8) u16 {
    return k_str[0] | (@intCast(u16, k_str[1]) << 8);
}

fn combinePair(k1: u16, k2: u16) u16 {
    return (k1 & BYTE_MASK) | ((k2 & BYTE_MASK) << 8);
}

fn increment(comptime K: type, comptime V: type, map: *std.AutoHashMap(K, V), key: K, value: V) !void {
    if (!map.contains(key)) {
        return map.put(key, value);
    } else {
        map.getPtr(key).?.* += value;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var alloc = &arena.allocator;
    defer arena.deinit();

    var rules = std.AutoHashMap(u16, u8).init(alloc);
    var pairs = std.AutoHashMap(u16, usize).init(alloc);
    var mutations = std.AutoHashMap(u16, usize).init(alloc);
    var chars = std.AutoHashMap(u8, usize).init(alloc);
    {
        var line_iter = std.mem.split(data, "\n");
        var tmpl_opt = line_iter.next();
        if (tmpl_opt) |tmpl| {
            var i: usize = 0;
            while(i < (tmpl.len - 1)) : (i += 1) {
                var kpair = convertPair(tmpl[i..i+2]);
                try increment(u16, usize, &pairs, kpair, 1);
                try increment(u8, usize, &chars, tmpl[i], 1);
            }
            try increment(u8, usize, &chars, tmpl[tmpl.len - 1], 1);
        }

        _ = line_iter.next();
        while(line_iter.next()) |line| {
            var iter = std.mem.split(line, " -> ");
            if (iter.next()) |k_str| {
                if (k_str.len > 0) {
                    var kpair = convertPair(k_str);
                    var val = iter.next().?[0];

                    try rules.put(kpair, val);
                    try mutations.put(kpair, 0);
                    if (!pairs.contains(kpair))
                        try pairs.put(kpair, 0);
                }
            }
        }
    }

    comptime var step: usize = 0;
    inline while(step < STEPS) : (step += 1) {
        // Evaluate all pairs "immutably"
        var iter = pairs.iterator();
        while(iter.next()) |it| {
            const value = it.value_ptr.*;
            if(value > 0) {
                const char_val = rules.get(it.key_ptr.*).?;
                try increment(u8, usize, &chars, char_val, value);

                var kpair1 = combinePair(it.key_ptr.*, @intCast(u16, char_val));
                var kpair2 = combinePair(@intCast(u16, char_val), (it.key_ptr.* >> 8));
                mutations.getPtr(kpair1).?.* += value;
                mutations.getPtr(kpair2).?.* += value;
                it.value_ptr.* -= value;
            }
        }

        // Apply mutations back to pairs
        iter = mutations.iterator();
        while(iter.next()) |mutation| {
            pairs.getPtr(mutation.key_ptr.*).?.* += mutation.value_ptr.*;
            mutation.value_ptr.* = 0;
        }
    }

    // Get result numbers
    var min: usize = std.math.maxInt(usize);
    var max: usize = 0;
    var len: usize = 0;
    var char_iter = chars.iterator();
    while(char_iter.next()) |it| {
        if (it.value_ptr.* < min) min = it.value_ptr.*;
        if (it.value_ptr.* > max) max = it.value_ptr.*;
        len += it.value_ptr.*;
    }

    var diff = max - min;
    std.debug.print("Polymer length: {d}\n", .{len});
    std.debug.print("Result: {d}\n", .{diff});
}
