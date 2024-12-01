const std = @import("std");
const ArrayList = std.ArrayList;

const Input = struct { first: []u32, second: []u32 };

const ParsedInputLine = struct { first: u32, second: u32 };

pub fn parseInputLine(line: []const u8) !ParsedInputLine {
    var elements = std.mem.splitSequence(u8, line, "   ");
    const first_raw = elements.next();
    const second_raw = elements.next();

    const first = try std.fmt.parseInt(u32, first_raw.?, 10);
    const second = try std.fmt.parseInt(u32, second_raw.?, 10);

    return ParsedInputLine{ .first = first, .second = second };
}

pub fn readInput(allocator: std.mem.Allocator) !Input {
    const raw = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 1024 * 1024);
    defer allocator.free(raw);
    var lines = std.mem.splitScalar(u8, raw, '\n');

    var first_array = ArrayList(u32).init(allocator);
    var second_array = ArrayList(u32).init(allocator);

    while (lines.next()) |line| {
        if (line.len != 0) {
            const parsed_line = try parseInputLine(line);
            try first_array.append(parsed_line.first);
            try second_array.append(parsed_line.second);
        }
    }

    return Input{
        .first = first_array.items,
        .second = second_array.items,
    };
}

pub fn solve_main(input: Input) u32 {
    std.mem.sort(u32, input.first, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, input.second, {}, comptime std.sort.asc(u32));
    var total_distance: u32 = 0;

    for (input.first, input.second) |first_element, second_element| {
        const diff = if (first_element > second_element) first_element - second_element else second_element - first_element;
        total_distance += diff;
    }

    return total_distance;
}

pub fn solve_bonus(allocator: std.mem.Allocator, input: Input) !u32 {
    var second_counter = std.AutoHashMap(u32, u32).init(allocator);
    defer second_counter.deinit();

    var total_distance: u32 = 0;

    for (input.second) |second_element| {
        const current_count = second_counter.get(second_element) orelse 0;
        const new_count = current_count + 1;
        try second_counter.put(second_element, new_count);
    }

    for (input.first) |first_element| {
        const second_count = second_counter.get(first_element) orelse 0;
        total_distance += first_element * second_count;
    }

    return total_distance;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try readInput(allocator);
    // const solution = solve_main(input);
    // std.debug.print("{any}\n", .{solution});
    const solution = solve_bonus(allocator, input);
    std.debug.print("{any}\n", .{solution});

    allocator.free(input.first);
    allocator.free(input.second);
}
