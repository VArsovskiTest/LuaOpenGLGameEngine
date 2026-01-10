Keyboard = {
    isPressed = {},      -- current frame: true if down
    wasPressed = {},     -- previous frame
    onPress = {}         -- callbacks: onPress["1"] = function() ... end
}

KeyboardState = {}

-- Call this at the very start of your update/tick
-- Keyboard.lua
function Keyboard.update()
    -- Prepare fresh state table
    Keyboard.isPressed = Keyboard.isPressed or {}   -- make sure it exists
    Keyboard.wasPressed = Keyboard.wasPressed or {}

    -- C# fill the fresh isPressed
    if Keyboard_update_from_csharp then
        -- We don't need to manually clear — we'll overwrite anyway
        -- (or do a shallow clear if you prefer)
        -- for k in pairs(Keyboard.isPressed) do Keyboard.isPressed[k] = nil end

        Keyboard_update_from_csharp(KeyboardState)     -- ←←← PASS THE STATE HERE
    end

    -- Now detect new presses
    for key, isDown in pairs(Keyboard.isPressed) do
        local wasDown = Keyboard.wasPressed[key] or false
        if isDown and not wasDown then
            local handler = Keyboard.onPress[key]
            if handler then handler() end
        end
    end

    -- Very important: prepare for next frame
    -- Keyboard.wasPressed = Keyboard.isPressed     -- reference is enough!
    -- or deep copy if you really need isolation:
    -- Keyboard.wasPressed = table.shallowcopy(Keyboard.isPressed)
    Keyboard.wasPressed = {}
    for k,v in pairs(Keyboard.isPressed) do
        Keyboard.wasPressed[k] = v
    end
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
