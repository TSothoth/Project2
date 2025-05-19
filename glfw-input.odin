package main

import "core:fmt"
import "core:strings"
import "vendor:glfw"

INPUT_HISTORY_SIZE :: 10

InputEvent :: struct {
    type: enum {
        KEY,
        MOUSE,
    },
    detail: string,
    timestamp: f64,
}

State :: struct {
    window: glfw.WindowHandle,
    input_events: [INPUT_HISTORY_SIZE]InputEvent,
    input_count: int,
    current_time: f64,
}

main :: proc() {
    state: State
    
    // Initialize GLFW
    if glfw.Init() != true {
        fmt.println("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()
    
    // Configure window hints
    glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)
    
    // Get primary monitor for fullscreen
    monitor := glfw.GetPrimaryMonitor()
    mode := glfw.GetVideoMode(monitor)
    
    // Create a fullscreen window
    state.window = glfw.CreateWindow(mode.width, mode.height, "Input Tracker", monitor, nil)
    if state.window == nil {
        fmt.println("Failed to create GLFW window")
        return
    }
    defer glfw.DestroyWindow(state.window)
    
    // Make the window's context current
    glfw.MakeContextCurrent(state.window)
    
    // Set up callbacks
    glfw.SetKeyCallback(state.window, key_callback)
    glfw.SetMouseButtonCallback(state.window, mouse_button_callback)
    
    // Set window user pointer to our state
    glfw.SetWindowUserPointer(state.window, &state)
    
    // Main loop
    for !glfw.WindowShouldClose(state.window) {
        state.current_time = glfw.GetTime()
        
        // Poll for and process events
        glfw.PollEvents()
        
        // Render
        render(&state)
        
        // Swap front and back buffers
        glfw.SwapBuffers(state.window)
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    state := cast(^State)glfw.GetWindowUserPointer(window)
    
    if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
        return
    }
    
    if action == glfw.PRESS || action == glfw.REPEAT {
        key_name := glfw.GetKeyName(key, scancode)
        if key_name == nil {
            // For special keys that don't have a printable name
            special_key_name := get_special_key_name(key)
            add_input_event(state, .KEY, fmt.tprintf("Key: %s", special_key_name))
        } else {
            add_input_event(state, .KEY, fmt.tprintf("Key: %s", key_name))
        }
    }
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
    state := cast(^State)glfw.GetWindowUserPointer(window)
    
    if action == glfw.PRESS {
        button_name := get_mouse_button_name(button)
        
        // Get mouse position
        x, y: f64
        glfw.GetCursorPos(window, &x, &y)
        
        add_input_event(state, .MOUSE, fmt.tprintf("Mouse: %s at (%.0f, %.0f)", button_name, x, y))
    }
}

add_input_event :: proc(state: ^State, type: InputEvent.type, detail: string) {
    if state.input_count == INPUT_HISTORY_SIZE {
        // Shift all events up to make room
        for i := 0; i < INPUT_HISTORY_SIZE-1; i += 1 {
            state.input_events[i] = state.input_events[i+1]
        }
        state.input_count = INPUT_HISTORY_SIZE - 1
    }
    
    event := InputEvent{
        type = type,
        detail = strings.clone(detail),
        timestamp = state.current_time,
    }
    
    state.input_events[state.input_count] = event
    state.input_count += 1
}

render :: proc(state: ^State) {
    // Clear screen
    glfw.SwapBuffers(state.window)
    
    width, height: i32
    glfw.GetFramebufferSize(state.window, &width, &height)
    
    // Set up simple text-based rendering
    glfw.SetWindowTitle(state.window, "Input Tracker - Press ESC to exit")
    
    // Print all input events to console for now (would need a proper rendering library for on-screen text)
    fmt.println("\n--- Current Input Events ---")
    fmt.println("Press ESC to exit")
    
    for i := 0; i < state.input_count; i += 1 {
        event := state.input_events[i]
        fmt.printf("[%.2fs] %s\n", event.timestamp, event.detail)
    }
}

get_special_key_name :: proc(key: i32) -> string {
    switch key {
        case glfw.KEY_SPACE: return "SPACE"
        case glfw.KEY_ESCAPE: return "ESCAPE"
        case glfw.KEY_ENTER: return "ENTER"
        case glfw.KEY_TAB: return "TAB"
        case glfw.KEY_BACKSPACE: return "BACKSPACE"
        case glfw.KEY_INSERT: return "INSERT"
        case glfw.KEY_DELETE: return "DELETE"
        case glfw.KEY_RIGHT: return "RIGHT"
        case glfw.KEY_LEFT: return "LEFT"
        case glfw.KEY_DOWN: return "DOWN"
        case glfw.KEY_UP: return "UP"
        case glfw.KEY_PAGE_UP: return "PAGE_UP"
        case glfw.KEY_PAGE_DOWN: return "PAGE_DOWN"
        case glfw.KEY_HOME: return "HOME"
        case glfw.KEY_END: return "END"
        case glfw.KEY_CAPS_LOCK: return "CAPS_LOCK"
        case glfw.KEY_SCROLL_LOCK: return "SCROLL_LOCK"
        case glfw.KEY_NUM_LOCK: return "NUM_LOCK"
        case glfw.KEY_PRINT_SCREEN: return "PRINT_SCREEN"
        case glfw.KEY_PAUSE: return "PAUSE"
        case glfw.KEY_F1: return "F1"
        case glfw.KEY_F2: return "F2"
        case glfw.KEY_F3: return "F3"
        case glfw.KEY_F4: return "F4"
        case glfw.KEY_F5: return "F5"
        case glfw.KEY_F6: return "F6"
        case glfw.KEY_F7: return "F7"
        case glfw.KEY_F8: return "F8"
        case glfw.KEY_F9: return "F9"
        case glfw.KEY_F10: return "F10"
        case glfw.KEY_F11: return "F11"
        case glfw.KEY_F12: return "F12"
        case glfw.KEY_LEFT_SHIFT: return "LEFT_SHIFT"
        case glfw.KEY_LEFT_CONTROL: return "LEFT_CONTROL"
        case glfw.KEY_LEFT_ALT: return "LEFT_ALT"
        case glfw.KEY_LEFT_SUPER: return "LEFT_SUPER"
        case glfw.KEY_RIGHT_SHIFT: return "RIGHT_SHIFT"
        case glfw.KEY_RIGHT_CONTROL: return "RIGHT_CONTROL"
        case glfw.KEY_RIGHT_ALT: return "RIGHT_ALT"
        case glfw.KEY_RIGHT_SUPER: return "RIGHT_SUPER"
        case: return fmt.tprintf("KEY_%d", key)
    }
}

get_mouse_button_name :: proc(button: i32) -> string {
    switch button {
        case glfw.MOUSE_BUTTON_LEFT: return "LEFT"
        case glfw.MOUSE_BUTTON_RIGHT: return "RIGHT"
        case glfw.MOUSE_BUTTON_MIDDLE: return "MIDDLE"
        case: return fmt.tprintf("BUTTON_%d", button)
    }
}
