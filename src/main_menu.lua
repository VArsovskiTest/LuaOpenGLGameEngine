-- main-menu.lua
return {
    title = "My Awesome Game",
    buttons = {
        { text = "Start Game", action = "start_game" },
        {
            text = "Options", 
            action = "open_options", 
            submenu = {
                { text = "Video", action = "open_video_settings" },
                { text = "Audio", action = "open_audio_settings" },
                { text = "Game", action = "open_game_settings" }
            }
        },
        { text = "Quit", action = "quit" }
    }
}
