-- Keyboard.lua
local log_handler = require("log_handler")

Keyboard = {
    isPressed = {},      -- current frame: true if down
    wasPressed = {},     -- previous frame
    onPress = {},         -- callbacks: onPress["1"] = function() ... end
    currentKey = nil
}

KeyboardState = {}

-- Call this at the very start of your update/tick
function Keyboard.update(gameState)
    if gameState then
        local keyboardState = gameState.KeyboardState or {}
        Keyboard.isPressed = keyboardState

        -- Prepare fresh state table
        Keyboard.isPressed = Keyboard.isPressed or {}   -- make sure it exists
        Keyboard.wasPressed = Keyboard.wasPressed or {}

        -- -- Reverse hook to pass KeyboardState back to C# (don't need but keep it just in case, for now)
        -- if Keyboard_update_from_csharp then Keyboard_update_from_csharp(KeyboardState or {}) end
    end

    -- Detect new presses
    for key, isDown in pairs(Keyboard.isPressed) do
        local wasDown = Keyboard.wasPressed[key] or false
        if isDown and not wasDown then
            Keyboard.currentKey = key
            local handler = Keyboard.onPress[key]
            if handler then
                if gameState then
                    handler(gameState.CurrentActor.ActorId, gameState.CurrentActor) -- Key is related to actor data
                else handler() end -- Key is test or non-related to actor data
            end
        end
    end

    -- Reset state
    Keyboard.wasPressed = {}
    for k,v in pairs(Keyboard.isPressed) do Keyboard.wasPressed[k] = v end
end

-- Helper to bind keys
function Keyboard.bind(key, callback)
    Keyboard.onPress[key] = callback
end

function Keyboard.unbind(key)
    Keyboard.onPress[key] = nil
end

function Keyboard.init()
    -- Clear everything to a known clean state
    Keyboard.isPressed = {}
    Keyboard.wasPressed = {}
    Keyboard.onPress = {}
end

function Keyboard.get_current_command_handler()
    return Keyboard.currentKey and Keyboard.onPress[Keyboard.currentKey] or nil
end

return Keyboard