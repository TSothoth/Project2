package main

import "core:fmt"
import "vendor:glfw"

WINDOW_TITLE :: "Fullscreen GLFW Window"
SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 960
TILE_SIZE :: 64
GRID_WIDTH :: SCREEN_WIDTH / TILE_SIZE
GRID_HEIGHT :: SCREEN_HEIGHT / TILE_SIZE

main :: proc() {
    if !glfw.Init() {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()

    monitor := glfw.GetPrimaryMonitor()
    if monitor == nil {
        fmt.eprintln("Failed to get primary monitor")
        return
    }
    
    video_mode := glfw.GetVideoMode(monitor)
    if video_mode == nil {
        fmt.eprintln("Failed to get video mode")
        return
    }
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.DECORATED, 0)  // Borderless
    glfw.WindowHint(glfw.RED_BITS, video_mode.red_bits)
    glfw.WindowHint(glfw.GREEN_BITS, video_mode.green_bits)
    glfw.WindowHint(glfw.BLUE_BITS, video_mode.blue_bits)
    glfw.WindowHint(glfw.REFRESH_RATE, video_mode.refresh_rate)

    window := glfw.CreateWindow(video_mode.width, video_mode.height, WINDOW_TITLE, nil, nil)
    if window == nil {
        fmt.eprintln("Failed to create GLFW window")
        return
    }
    defer glfw.DestroyWindow(window)

    glfw.MakeContextCurrent(window)
    
    key_callback :: proc "c" (window: glfw.WindowHandle, key: i32, scancode: i32, action: i32, mods: i32) {
        if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
            glfw.SetWindowShouldClose(window, true)
        }
    }
    
    glfw.SetKeyCallback(window, key_callback)
    
    fmt.println("Window created successfully")
    fmt.println("Press ESC to exit")
    
// Main loop
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        width, height := glfw.GetFramebufferSize(window)
        




        glfw.SwapBuffers(window)
    }

    fmt.println("Window closed successfully")
}
