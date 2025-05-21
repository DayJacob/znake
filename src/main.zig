const std = @import("std");
const rl = @import("raylib");

const Vec2 = rl.Vector2;

const SCREEN_SIZE = 700;
const CELL_SIZE = 50;
const GRID_WIDTH = SCREEN_SIZE / CELL_SIZE;

const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const Snake = struct {
    position: [GRID_WIDTH * GRID_WIDTH]Vec2,
    direction: Direction,
    length: u8,

    pub fn drawPlayer(pl: Snake) void {
        for (0..pl.length) |i| {
            rl.drawRectangle(@intFromFloat(pl.position[i].x), @intFromFloat(pl.position[i].y), CELL_SIZE, CELL_SIZE, .green);
        }
    }
};

const Game = struct {
    isRunning: bool,
    player: *Snake,
    item: Vec2,
    score: u32,

    pub fn drawFood(game: Game) void {
        rl.drawCircle(@intFromFloat(@as(f32, CELL_SIZE) * (game.item.x + 1) / 2), @intFromFloat(@as(f32, CELL_SIZE) * (game.item.y + 1) / 2), @floatFromInt(CELL_SIZE / 2), .red);
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    rl.initWindow(SCREEN_SIZE, SCREEN_SIZE, "znake");
    defer rl.closeWindow();

    var player = Snake{
        .position = undefined,
        .direction = Direction.RIGHT,
        .length = 3,
    };

    for (0..player.length) |i| {
        player.position[i] = Vec2.init(0, 0);
    }

    const game = Game{
        .isRunning = true,
        .item = Vec2.init(@floatFromInt(rl.getRandomValue(0, GRID_WIDTH)), @floatFromInt(rl.getRandomValue(0, GRID_WIDTH))),
        .score = 0,
        .player = &player,
    };

    try stdout.print("Food drawn at cell {d},{d}\n", .{ game.item.x, game.item.y });
    try stdout.print("Actual grid position: {d}, {d}\n", .{ @as(f32, CELL_SIZE) * (game.item.x + 1) / 2, @as(f32, CELL_SIZE) * (game.item.y + 1) / 2 });

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        var i: i32 = 0;
        while (i <= SCREEN_SIZE) {
            rl.drawLine(i, 0, i, SCREEN_SIZE, .dark_gray);
            rl.drawLine(0, i, SCREEN_SIZE, i, .dark_gray);
            i += CELL_SIZE;
        }

        game.player.drawPlayer();
        game.drawFood();
    }
}
