const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const res = @import("res.zig");
const state = @import("state.zig");

const title = "Calculo Testing UI";
const width = 640;
const height = 480;

pub fn run(alloc: *std.mem.Allocator) anyerror!void {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const allocator = &arena.allocator;

    ray.InitWindow(width, height, title);
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    const cur_state = try allocator.create(state.UIState);

    try state.init_main_menu(allocator, cur_state);

    while (!ray.WindowShouldClose()) {
        switch (cur_state.*.screen) {
            .main_menu => try handle_main_menu(allocator, cur_state),
            .controller_configuration => try handle_controller_configuration(allocator, cur_state),
            else => unreachable,
        }
    }
}

pub fn handle_main_menu(allocator: *std.mem.Allocator, cur_state: *state.UIState) !void {
    const main_menu_state = cur_state.screen.main_menu;
    if (ray.IsKeyPressed(ray.KEY_UP)) {
        main_menu_state.*.selected_button = main_menu_state.*.selected_button.previous();
    }
    if (ray.IsKeyPressed(ray.KEY_DOWN)) {
        main_menu_state.*.selected_button = main_menu_state.*.selected_button.next();
    }

    ray.BeginDrawing();

    ray.ClearBackground(ray.RAYWHITE);

    const mm_text = title;
    const mm_size = 60;
    const mm_offset = @divTrunc(ray.MeasureText(mm_text, mm_size), 2);
    ray.DrawText(mm_text, @divTrunc(width, 2) - mm_offset, 24, mm_size, ray.LIGHTGRAY);

    const go_text = "Go";
    const go_size = 20;
    const go_offset = @divTrunc(ray.MeasureText(go_text, go_size), 2);

    const go_color = if (main_menu_state.selected_button == .go) ray.RED else ray.DARKGRAY;

    ray.DrawText(go_text, @divTrunc(width, 2) - go_offset, 300, go_size, go_color);

    const conf_text = "Configure Controllers";
    const conf_size = 20;
    const conf_offset = @divTrunc(ray.MeasureText(conf_text, conf_size), 2);

    const conf_color = if (main_menu_state.selected_button == .configure_controllers) ray.RED else ray.DARKGRAY;

    ray.DrawText(conf_text, @divTrunc(width, 2) - conf_offset, 340, conf_size, conf_color);

    ray.EndDrawing();

    if (ray.IsKeyPressed(ray.KEY_ENTER)) {
        if (main_menu_state.*.selected_button == .configure_controllers) {
            try state.main_menu_to_controller_configuration(allocator, cur_state);
        }
    }
}

pub fn handle_controller_configuration(allocator: *std.mem.Allocator, cur_state: *state.UIState) !void {
    const controller_configuration_state = cur_state.screen.controller_configuration;

    ray.BeginDrawing();

    ray.ClearBackground(ray.RAYWHITE);

    ray.EndDrawing();

    if (ray.IsKeyPressed(ray.KEY_BACKSPACE)) {
        try state.controller_configuration_to_main_menu(allocator, cur_state);
    }
}
