require "scripts.utility"

PIXEL_SCALE = 1
BLOCK_WIDTH = 16

ROOM_W, ROOM_H = 30, 18
ROOM_PIXEL_W, ROOM_PIXEL_H = ROOM_W*BLOCK_WIDTH, ROOM_H*BLOCK_WIDTH
MAIN_PATH_Y = 7
MAIN_PATH_PIXEL_Y = MAIN_PATH_Y*ROOM_PIXEL_H

COLORS_PLAYERS = {
    [1] = color(0xfee761),
    [2] = color(0x2ce8f5),
    [3] = color(0x63c74d),
    [4] = color(0xf6757a),
}