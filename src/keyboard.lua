Keyboard = {
    isPressed = {},      -- current frame: true if down
    wasPressed = {},     -- previous frame
    onPress = {}         -- callbacks: onPress["1"] = function() ... end
}

-- Call this at the very start of your update/tick
function Keyboard.update()
    -- Swap
    -- Keyboard.wasPressed, Keyboard.isPressed = Keyboard.isPressed, Keyboard.wasPressed

    -- C# fill
    if Keyboard_update_from_csharp then
        -- Clear the new isPressed (old wasPressed)
        for k in pairs(Keyboard.isPressed) do
            Keyboard.isPressed[k] = nil
        end

        Keyboard_update_from_csharp()
    end

    -- Detect
    for key, isDown in pairs(Keyboard.isPressed) do
        if isDown then
            if not Keyboard.wasPressed[key] then  -- nil treated as not down
                local handler = Keyboard.onPress[key]
                if handler then handler() end
            end
        end
    end

    -- Update to prevent duplicate/s
    -- Keyboard.wasPressed = Keyboard.isPressed
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

    -- local common_keys = {
    --     "1","2","3","4","5","6","7","8","9","0",
    --     "q","w","e","r","t","y","u","i","o","p",
    --     "a","s","d","f","g","h","j","k","l",
    --     "z","x","c","v","b","n","m",
    --     "space","enter","tab","shift","ctrl","alt",
    --     "escape","backspace",
    --     "numpad1","numpad2","numpad3",
    --     "numpad4","numpad5","numpad6",
    --     "numpad7","numpad8","numpad9", "numpad0"
    -- }

    -- for _, key in ipairs(common_keys) do
    --     Keyboard.isPressed[key] = false
    --     Keyboard.wasPressed[key] = false
    --     -- Note: onPress[key] remains nil until bound
    -- end
end

return Keyboard
