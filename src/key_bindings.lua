local Keyboard = require("keyboard")
local ActorActions = require("actor_actions")
local table_helper = require("table_helper")

local DefaultBindings = {
    handle_move_up = "w",
    handle_move_down = "s",
    handle_move_left = "a",
    handle_move_right = "d",
    handle_jump = "j",
    handle_attack = "k",
    handle_attack_alt = "l",
    handle_defend = "u",
    handle_sprint = "shift",
    handle_boost = "alt",
    handle_map = "tab",
    handle_use_consumable = "q",
    handle_engage = "e",
    handle_swap_main_attack = "g",
    handle_swap_alt_attack = "h",
    handle_select_1 = "1",
    handle_select_2 = "2",
    handle_select_3 = "3",
    handle_select_4 = "4",
    handle_select_5 = "5",
    handle_select_6 = "6",
    handle_select_7 = "7",
    handle_select_8 = "8",
    handle_select_9 = "9",
    handle_select_0 = "0",
}

-- Current active bindings (can be changed at runtime or loaded from config)
local CurrentBindings = {}

local ActionHandlers = {
    handle_move_up = function()
        CommandQueue.enqueue({ name = "move_up", command = ActorActions.handle_move_up() })
    end,
    handle_move_down = function()
        CommandQueue.enqueue({ name = "move_down", command = ActorActions.handle_move_down() })
    end,
    handle_move_left = function()
        CommandQueue.enqueue({ name = "move_left", command = ActorActions.handle_move_left() })
    end,
    handle_move_right = function()
        CommandQueue.enqueue({ name = "move_right", command = ActorActions.handle_move_right() })
    end,
    handle_jump = function()
        CommandQueue.enqueue({ name = "jump", command = ActorActions.handle_jump() })
    end,
    handle_attack = function()
        CommandQueue.enqueue({ name = "attack", command = ActorActions.handle_attack() })
    end,
    handle_attack_alt = function()
        CommandQueue.enqueue({ name = "attack_alt", command = ActorActions.handle_attack_alt() })
    end,
    handle_defend = function()
        CommandQueue.enqueue({ name = "defend", command = ActorActions.handle_defend() })
    end,
    handle_sprint = function()
        CommandQueue.enqueue({ name = "sprint", command = ActorActions.handle_sprint() })
    end,
    handle_boost = function()
        CommandQueue.enqueue({ name = "boost", command = ActorActions.handle_boost() })
    end,
    handle_map = function()
        CommandQueue.enqueue({ name = "map", command = ActorActions.handle_map() })
    end,
    handle_use_consumable = function()
        CommandQueue.enqueue({ name = "use_consumable", command = ActorActions.handle_use_consumable() })
    end,
    handle_engage = function()
        CommandQueue.enqueue({ name = "engage", command = ActorActions.handle_engage() })
    end,
    handle_swap_main_attack = function()
        CommandQueue.enqueue({ name = "swap_main_attack", command = ActorActions.handle_swap_main_attack() })
    end,
    handle_swap_alt_attack = function()
        CommandQueue.enqueue({ name = "swap_alt_attack", command = ActorActions.handle_swap_alt_attack() })
    end,
    handle_select_1 = function()
        CommandQueue.enqueue({ name = "select_1", command = ActorActions.handle_select_1() })
    end,
    handle_select_2 = function()
        CommandQueue.enqueue({ name = "select_2", command = ActorActions.handle_select_2() })
    end,
    handle_select_3 = function()
        CommandQueue.enqueue({ name = "select_3", command = ActorActions.handle_select_3() })
    end,
    handle_select_4 = function()
        CommandQueue.enqueue({ name = "select_4", command = ActorActions.handle_select_4() })
    end,
    handle_select_5 = function()
        CommandQueue.enqueue({ name = "select_5", command = ActorActions.handle_select_5() })
    end,
    handle_select_6 = function()
        CommandQueue.enqueue({ name = "select_6", command = ActorActions.handle_select_6() })
    end,
    handle_select_7 = function()
        CommandQueue.enqueue({ name = "select_7", command = ActorActions.handle_select_7() })
    end,
    handle_select_8 = function()
        CommandQueue.enqueue({ name = "select_8", command = ActorActions.handle_select_8() })
    end,
    handle_select_9 = function()
        CommandQueue.enqueue({ name = "select_9", command = ActorActions.handle_select_9() })
    end,
    handle_select_0 = function()
        CommandQueue.enqueue({ name = "select_0", command = ActorActions.handle_select_0() })
    end,
}

-- Apply bindings: register all current key → handler with Keyboard system
local function apply_bindings()
    -- First clear old ones (optional, if rebinding)
    Keyboard.onPress = {}  -- careful: better to just overwrite

    for action_name, key in pairs(CurrentBindings) do
        local handler = ActionHandlers[action_name]
        if handler then
            Keyboard.bind(key, handler)
        else
            print("Warning: No handler for action " .. action_name)
        end
    end
end

-- Load defaults
local function bind_defaults()
    CurrentBindings = {}
    for action, key in pairs(DefaultBindings) do
        CurrentBindings[action] = key
    end
    apply_bindings()
end

-- Change a single binding (e.g., from settings menu or config file)
local function bind_action(action_name, new_key)
    local previous_binding = table_helper.tryGetValue(CurrentBindings, new_key)
    if ActionHandlers[action_name] then
        if previous_binding then
            local previous_key = CurrentBindings[action_name]
            CurrentBindings[previous_binding] = previous_key
        end
        CurrentBindings[action_name] = new_key
        apply_bindings()  -- re-register all (simple but effective)
        print("Bound '" .. new_key .. "' to " .. action_name)
    else
        print("Unknown action: " .. action_name)
    end
end

local function get_key_for_action(action_name)
    return CurrentBindings[action_name] or DefaultBindings[action_name]
end

-- Init
bind_defaults()

function save_keybinds(filename)
    local file = io.open(filename, "w")
    for action, key in pairs(CurrentBindings) do
        file:write(action .. "=" .. key .. "\n")
    end
    file:close()
end

function load_keybinds(filename)
    CurrentBindings = {}
    for line in io.lines(filename) do
        local action, key = line:match("([^=]+)=([^=]+)")
        if action and key then
            CurrentBindings[action] = key
        end
    end
    apply_bindings()
end

-- Exported module
return {
    bind_defaults = bind_defaults,
    bind_action = bind_action,
    get_key_for_action = get_key_for_action,
    apply_bindings = apply_bindings,
    DefaultBindings = DefaultBindings,
    CurrentBindings = CurrentBindings,
}
