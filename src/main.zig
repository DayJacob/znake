const std = @import("std");
const rl = @import("raylib");

const Vec2 = rl.Vector2;

const SCREEN_SIZE = 700;
const CELL_SIZE = 50;
const GRID_WIDTH = SCREEN_SIZE / CELL_SIZE;
const TICK_SPEED = 5;
const MAX_SNAKE_LEN = 256;
const POS_HEAD = 0;

const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const Snake = struct {
    position: [MAX_SNAKE_LEN]Vec2,
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
    moveAllowed: bool,
    prevPos: [MAX_SNAKE_LEN]Vec2,
    frameCounter: u64,

    pub fn drawFood(game: Game) void {
        // 0 -> 25; 1 -> 75; etc.
        // f(x) = 25 + 50x
        rl.drawCircle(@intFromFloat(CELL_SIZE / 2 + CELL_SIZE * game.item.x), @intFromFloat(CELL_SIZE / 2 + CELL_SIZE * game.item.y), CELL_SIZE / 2, .red);
    }

    pub fn tick(game: *Game) !void {
        _ = std.io.getStdOut().writer();

        if (game.*.isRunning) {
            const pl = game.*.player;

            // poll for direction
            if (rl.isKeyPressed(.right) and game.*.moveAllowed) {
                pl.*.direction = Direction.RIGHT;
                game.*.moveAllowed = false;
            } else if (rl.isKeyPressed(.left) and game.*.moveAllowed) {
                pl.*.direction = Direction.LEFT;
                game.*.moveAllowed = false;
            } else if (rl.isKeyPressed(.down) and game.*.moveAllowed) {
                pl.*.direction = Direction.DOWN;
                game.*.moveAllowed = false;
            } else if (rl.isKeyPressed(.up) and game.*.moveAllowed) {
                pl.*.direction = Direction.UP;
                game.*.moveAllowed = false;
            }

            for (0..pl.*.length) |i| {
                game.*.prevPos[i] = pl.*.position[i];
            }

            if (game.*.frameCounter % TICK_SPEED == 0) {
                switch (pl.*.direction) {
                    .DOWN => {
                        pl.*.position[POS_HEAD].y += CELL_SIZE;
                    },
                    .UP => {
                        pl.*.position[POS_HEAD].y -= CELL_SIZE;
                    },
                    .LEFT => {
                        pl.*.position[POS_HEAD].x -= CELL_SIZE;
                    },
                    .RIGHT => {
                        pl.*.position[POS_HEAD].x += CELL_SIZE;
                    },
                }
                game.*.moveAllowed = true;

                for (1..pl.*.length) |i| {
                    pl.*.position[i] = game.*.prevPos[i - 1];
                }
            }

            game.*.frameCounter += 1;
        }
    }

    pub fn render(game: Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        var i: i32 = 0;
        while (i <= SCREEN_SIZE) {
            rl.drawLine(i, 0, i, SCREEN_SIZE, .dark_gray);
            rl.drawLine(0, i, SCREEN_SIZE, i, .dark_gray);
            i += CELL_SIZE;
        }

        game.drawFood();
        game.player.*.drawPlayer();
    }
};

pub fn main() !void {
    rl.initWindow(SCREEN_SIZE, SCREEN_SIZE, "znake");
    defer rl.closeWindow();

    var player = Snake{
        .position = undefined,
        .direction = Direction.DOWN,
        .length = 3,
    };

    for (0..player.length) |i| {
        player.position[i] = Vec2.init(0, 0);
    }

    var game = Game{
        .isRunning = true,
        .item = Vec2.init(@floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1)), @floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1))),
        .score = 0,
        .player = &player,
        .moveAllowed = false,
        .prevPos = undefined,
        .frameCounter = 0,
    };

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // update game
        try game.tick();

        // draw game
        game.render();
    }
}
