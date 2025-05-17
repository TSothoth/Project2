package main

import "core:fmt"
import "core:math"
import "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 960
TILE_SIZE :: 64
GRID_WIDTH :: SCREEN_WIDTH / TILE_SIZE
GRID_HEIGHT :: SCREEN_HEIGHT / TILE_SIZE

Tile :: struct {
    texture: raylib.Texture2D,
    position: raylib.Vector2,       // should be what ?
    color: raylib.Color,
    is_visible: bool,
}

Game :: struct {
    tiles: [GRID_WIDTH][GRID_HEIGHT]Tile,
}

create_tile :: proc(texture: raylib.Texture2D, x, y: i32, color: raylib.Color) -> Tile {
    return Tile{
        texture = texture,
        position = raylib.Vector2{f32(x * TILE_SIZE), f32(y * TILE_SIZE)},
        color = color,
        is_visible = true,
    }
}

draw_tile :: proc(tile: Tile) {
    if tile.is_visible {
        raylib.DrawTextureEx(tile.texture, tile.position, 0, 1, tile.color)
    }
}

init_game :: proc() -> Game {
    game: Game
    return game
}



main :: proc() {
    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "DQRL")  //
    defer raylib.CloseWindow()                              //
    
    raylib.SetTargetFPS(60)
    
    sprite_texture := raylib.LoadTexture("grimp-64.png")  // Load resources
    defer raylib.UnloadTexture(sprite_texture)
    

    game := init_game()                                     // Create basic game with some visible tiles
    
    for x in 0..<GRID_WIDTH {                                       // Add some sample tiles to visualize our grid
        for y in 0..<GRID_HEIGHT {
            game.tiles[x][y] = create_tile(sprite_texture, i32(x), i32(y), raylib.WHITE) //
        }
    }
    
    for !raylib.WindowShouldClose() {                       // Game loop
        // Update game logic here

















        raylib.BeginDrawing()                               // doesn't actually do anything but mark beginning
        defer raylib.EndDrawing()                           // swaps buffers
        
        raylib.ClearBackground(raylib.BLACK)
        
        // Draw all visible tiles
        for x in 0..<GRID_WIDTH {
            for y in 0..<GRID_HEIGHT {
                if game.tiles[x][y].is_visible {
                    draw_tile(game.tiles[x][y])
                }
            }
        }
        
        // Display grid dimensions
        raylib.DrawText(fmt.ctprintf("Grid: %dx%d (Tiles: %dx%d)", 
                        SCREEN_WIDTH, SCREEN_HEIGHT, GRID_WIDTH, GRID_HEIGHT), 
                        10, 10, 10, raylib.WHITE)
    }
}
