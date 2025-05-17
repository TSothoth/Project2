package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"
import "core:strconv"
import "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 960
TILE_SIZE :: 64
GRID_WIDTH :: SCREEN_WIDTH / TILE_SIZE  // 16 tiles wide
GRID_HEIGHT :: SCREEN_HEIGHT / TILE_SIZE // 15 tiles high

// struct for basic tile data
Tile :: struct {
    texture: raylib.Texture2D,  // opengl texture id
    position: raylib.Vector2,   // 2 item array, coordinates on screen
    color: raylib.Color,        // enum
    is_visible: bool,
}

TileType :: enum {
    Empty = 0,
    Ground = 1,
    Wall = 2,
    Water = 3,
    Player = 4,
}


Game :: struct {
    tiles: [GRID_WIDTH][GRID_HEIGHT]Tile,
    tile_textures: map[TileType]raylib.Texture2D,
}

create_tile :: proc(texture: raylib.Texture2D, x, y: i32, color: raylib.Color = raylib.WHITE) -> Tile {
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

load_tilemap_from_csv :: proc(filepath: string, game: ^Game) -> bool {
    // Read the file
    data, ok := os.read_entire_file(filepath)
    if !ok {
        fmt.println("Failed to read CSV file:", filepath)
        return false
    }
    defer delete(data)

    content := string(data)
    lines := strings.split(content, "\n")
    defer delete(lines)

    // Process each line of the CSV
    for y in 0..<min(len(lines), GRID_HEIGHT) {
        line := strings.trim(lines[y], " \r\t")
        if line == "" {
            continue
        }

        values := strings.split(line, ",")
        defer delete(values)

        for x in 0..<min(len(values), GRID_WIDTH) {
            value_str := strings.trim(values[x], " \r\t")
            if value_str == "" {
                continue
            }

            // Parse the tile type from the CSV value
            value, parse_ok := strconv.parse_int(value_str)
            if !parse_ok {
                fmt.println("Failed to parse tile value:", value_str)
                continue
            }

            tile_type := TileType(value)

            // Set the tile properties based on its type
            if texture, has_texture := game.tile_textures[tile_type]; has_texture {
                // Create tile with default WHITE color (no tint)
                game.tiles[x][y] = create_tile(texture, i32(x), i32(y))
                game.tiles[x][y].is_visible = tile_type != .Empty
            }
        }
    }

    fmt.println("Tilemap loaded successfully from:", filepath)
    return true
}

init_game :: proc() -> Game {
    game: Game
    game.tile_textures = make(map[TileType]raylib.Texture2D)
    return game
}

main :: proc() {
    // Initialize window
    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Odin Raylib Game")
    defer raylib.CloseWindow()

    raylib.SetTargetFPS(60)

    // Load resources
    ground_texture := raylib.LoadTexture("ground.png")
    wall_texture := raylib.LoadTexture("wall.png")
    water_texture := raylib.LoadTexture("water.png")
    player_texture := raylib.LoadTexture("grimp-32.png")

    // Create game and assign textures to tile types
    game := init_game()
    game.tile_textures[.Ground] = ground_texture
    game.tile_textures[.Wall] = wall_texture
    game.tile_textures[.Water] = water_texture
    game.tile_textures[.Player] = player_texture

    // Cleanup resources when done
    defer {
        raylib.UnloadTexture(ground_texture)
        raylib.UnloadTexture(wall_texture)
        raylib.UnloadTexture(water_texture)
        raylib.UnloadTexture(player_texture)
        delete(game.tile_textures)
    }

    // Load tilemap from CSV file
    if !load_tilemap_from_csv("tilemap.csv", &game) {
        fmt.println("Failed to load tilemap, using default map")

        // Create a default map if CSV loading fails
        for x in 0..<10 {
            for y in 0..<5 {
                game.tiles[x][y] = create_tile(ground_texture, i32(x), i32(y))
            }
        }

        for x in 15..<25 {
            for y in 20..<25 {
                game.tiles[x][y] = create_tile(water_texture, i32(x), i32(y))
            }
        }

        // Add a player in the middle
        game.tiles[GRID_WIDTH/2][GRID_HEIGHT/2] = create_tile(player_texture, i32(GRID_WIDTH/2), i32(GRID_HEIGHT/2))
    }

    // Game loop
    for !raylib.WindowShouldClose() {
        // Update game logic here

        // Drawing
        raylib.BeginDrawing()
        defer raylib.EndDrawing()

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
