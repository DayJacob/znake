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
    const Self = @This();

    position: [MAX_SNAKE_LEN]Vec2,
    direction: Direction,
    length: u8,

    pub fn init(pl: *Self) void {
        pl.*.position = undefined;
        pl.*.direction = Direction.DOWN;
        pl.*.length = 3;

        for (0..pl.*.length) |i| {
            pl.*.position[i] = Vec2.init(0, 0);
        }
    }

    pub fn drawPlayer(pl: Self) void {
        for (0..pl.length) |i| {
            rl.drawRectangle(@intFromFloat(pl.position[i].x), @intFromFloat(pl.position[i].y), CELL_SIZE, CELL_SIZE, .green);
        }
    }
};

const Game = struct {
    const Self = @This();

    isRunning: bool,
    player: *Snake,
    item: Vec2,
    score: u32,
    moveAllowed: bool,
    prevPos: [MAX_SNAKE_LEN]Vec2,
    frameCounter: u64,

    pub fn init(game: *Self) void {
        game.*.isRunning = true;
        game.*.item = Vec2.init(@floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1) * CELL_SIZE), @floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1) * CELL_SIZE));
        game.*.score = 0;
        game.*.moveAllowed = false;
        game.*.prevPos = undefined;
        game.*.frameCounter = 0;
        game.*.player.*.init();
    }

    pub fn drawFood(game: Self) void {
        // 0 -> 25; 1 -> 75; etc.
        // f(x) = 25 + 50x
        rl.drawCircle(@intFromFloat(CELL_SIZE / 2 + game.item.x), @intFromFloat(CELL_SIZE / 2 + game.item.y), CELL_SIZE / 2, .red);
    }

    pub fn tick(game: *Self) void {
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

            if (@mod(game.*.frameCounter, TICK_SPEED) == 0) {
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

            // check collision with food
            if (pl.*.position[POS_HEAD].x == game.*.item.x and pl.*.position[POS_HEAD].y == game.*.item.y) {
                game.*.score += 10;
                pl.*.position[pl.*.length] = game.*.prevPos[pl.*.length - 1];
                pl.*.length += 1;

                game.*.item = Vec2.init(@floatFromInt(rl.getRandomValue(0, GRID_WIDTH - 1) * CELL_SIZE), @floatFromInt(rl.getRandomValue(0, GRID_WIDTH - 1) * CELL_SIZE));
            }

            // check collision with wall
            if (pl.*.position[POS_HEAD].x >= SCREEN_SIZE or pl.*.position[POS_HEAD].x < 0 or pl.*.position[POS_HEAD].y >= SCREEN_SIZE or pl.*.position[POS_HEAD].y < 0) {
                game.*.isRunning = false;
            }

            // check collision with self
            for (1..pl.*.length) |i| {
                if (pl.*.position[POS_HEAD].x == pl.*.position[i].x and pl.*.position[POS_HEAD].y == pl.*.position[i].y) {
                    game.*.isRunning = false;
                }
            }

            game.*.frameCounter += 1;
        } else {
            if (rl.isKeyPressed(.enter)) {
                game.*.init();
            }
        }
    }

    pub fn render(game: Self) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        if (game.isRunning) {
            var i: i32 = 0;
            while (i <= SCREEN_SIZE) {
                rl.drawLine(i, 0, i, SCREEN_SIZE, .dark_gray);
                rl.drawLine(0, i, SCREEN_SIZE, i, .dark_gray);
                i += CELL_SIZE;
            }

            game.drawFood();
            game.player.*.drawPlayer();
        } else {
            rl.drawText("Game over! Press ENTER to restart.", @divFloor(SCREEN_SIZE - rl.measureText("Game over! Press ENTER to restart.", 25), 2), SCREEN_SIZE / 2 - 35, 25, .black);
            rl.drawText(rl.textFormat("Your score: %i", .{game.score}), @divFloor(SCREEN_SIZE - rl.measureText(rl.textFormat("Your score: %i", .{game.score}), 25), 2), SCREEN_SIZE / 2, 25, .black);
        }
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
        .item = Vec2.init(@floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1) * CELL_SIZE), @floatFromInt(rl.getRandomValue(1, GRID_WIDTH - 1) * CELL_SIZE)),
        .score = 0,
        .player = &player,
        .moveAllowed = false,
        .prevPos = undefined,
        .frameCounter = 0,
    };

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // update game
        game.tick();

        // draw game
        game.render();
    }
}
