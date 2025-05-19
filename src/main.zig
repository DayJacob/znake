pub fn main() !void {
    const screenSize = 720;

    rl.initWindow(screenSize, screenSize, "zig raylib test");
    defer rl.closeWindow();

    const camera = rl.Camera2D{
        .target = .init(0, 0),
        .offset = .init(screenSize / 2, screenSize / 2),
        .rotation = 0,
        .zoom = 1,
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        camera.begin();
        defer camera.end();
    }
}

const std = @import("std");
const rl = @import("raylib");
