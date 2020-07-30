const std = @import("std");

const puyo = @import("puyo/puyo.zig");

const state = @import("calculo/state.zig");
const provider = @import("calculo/provider.zig");

const algae = @cImport({
    @cInclude("algae.h");
});

const TestProvider = struct {
    lstate: state.GameState = state.GameState{
        .colors = &[_]puyo.ColorId{ 0, 1, 2, 3 },
        .board = [1][puyo.board_width]puyo.Tile{[1]puyo.Tile{.empty} ** puyo.board_width} ** puyo.board_height,
        .current_piece = state.CurrentPiece{
            .piece = puyo.Piece{
                .drop = puyo.drops.i,
                .colors = &[2]puyo.ColorId{ 1, 2 },
            },
            .rotation = state.PieceRotation.Up,
            .position = [2]u8{ 0, 0 }, // TODO name common positions
        },
        .queue = [2]puyo.Piece{
            puyo.Piece{
                .drop = puyo.drops.i,
                .colors = &[2]puyo.ColorId{ 0, 0 },
            },
            puyo.Piece{
                .drop = puyo.drops.i,
                .colors = &[2]puyo.ColorId{ 2, 3 },
            },
        },
    },
    pub const Self = @This();
    pub fn init(self: *const Self) void {
        std.debug.print("Hello!", .{});
    }
    pub fn pull(self: *const Self) state.GameState {
        return self.lstate;
    }
};

pub fn main() anyerror!void {
    // var tprovider = TestProvider{};
    // provider.do_thing(tprovider);
    // try @import("ui/ui.zig").run(std.heap.c_allocator);
    const alloc = std.heap.c_allocator;

    const conf = algae.futhark_context_config_new();
    defer algae.futhark_context_config_free(conf);
    const ctx = algae.futhark_context_new(conf);
    defer algae.futhark_context_free(ctx);

    var data: [1]u32 = [_]u32{0};
    const input = algae.futhark_new_u32_2d(ctx, &data, 1, 1);
    defer _ = algae.futhark_free_u32_2d(ctx, input);

    var out: *bool = try alloc.create(bool);
    defer alloc.destroy(out);

    _ = algae.futhark_entry_main(ctx, out, input);

    std.debug.print("The result should be true: {}\n", .{out.*});
}
