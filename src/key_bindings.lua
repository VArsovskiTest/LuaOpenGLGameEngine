local Keyboard = require("keyboard")
local ActorActions = require("actor_actions")
local table_helper = require("table_helper")
local log_handler = require("log_handler")

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
    handle_move_up = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "move_up", command = ActorActions.handle_move_up(id, cmd) }) end,
    handle_move_down = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "move_down", command = ActorActions.handle_move_down(id, cmd) }) end,
    handle_move_left = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "move_left", command = ActorActions.handle_move_left(id, cmd) }) end,
    handle_move_right = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "move_right", command = ActorActions.handle_move_right(id, cmd) }) end,
    handle_use_consumable = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "use_consumable", command = ActorActions.handle_use_consumable(id, cmd) }) end,
    handle_jump = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "jump", command = ActorActions.handle_jump(id, cmd) }) end,
    handle_attack = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "attack", command = ActorActions.handle_attack(id, cmd) }) end,
    handle_attack_alt = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "attack_alt", command = ActorActions.handle_attack_alt(id, cmd) }) end,
    handle_defend = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "defend", command = ActorActions.handle_defend(id, cmd) }) end,
    handle_sprint = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "sprint", command = ActorActions.handle_sprint(id, cmd) }) end,
    handle_boost = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "boost", command = ActorActions.handle_boost(id, cmd) }) end,
    handle_map = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "map", command = ActorActions.handle_map(id, cmd) }) end,
    handle_engage = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "engage", command = ActorActions.handle_engage(id, cmd) }) end,
    handle_swap_main_attack = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "swap_main_attack", command = ActorActions.handle_swap_main_attack(id, cmd) }) end,
    handle_swap_alt_attack = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "swap_alt_attack", command = ActorActions.handle_swap_alt_attack(id, cmd) }) end,
    handle_select_1 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_1", command = ActorActions.handle_select_1(id, cmd) }) end,
    handle_select_2 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_2", command = ActorActions.handle_select_2(id, cmd) }) end,
    handle_select_3 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_3", command = ActorActions.handle_select_3(id, cmd) }) end,
    handle_select_4 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_4", command = ActorActions.handle_select_4(id, cmd) }) end,
    handle_select_5 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_5", command = ActorActions.handle_select_5(id, cmd) }) end,
    handle_select_6 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_6", command = ActorActions.handle_select_6(id, cmd) }) end,
    handle_select_7 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_7", command = ActorActions.handle_select_7(id, cmd) }) end,
    handle_select_8 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_8", command = ActorActions.handle_select_8(id, cmd) }) end,
    handle_select_9 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_9", command = ActorActions.handle_select_9(id, cmd) }) end,
    handle_select_0 = function(id, cmd) cmd.entity_id = id CommandQueue:enqueue(id, { name = "select_0", command = ActorActions.handle_select_0(id, cmd) }) end,
}

-- Apply bindings: register all current key → handler with Keyboard system
local function apply_bindings()
    -- First clear old ones (optional, if rebinding)
    Keyboard.onPress = {}  -- careful: better to just overwrite

    for action_name, key in pairs(CurrentBindings) do

        log_handler.log_data("key: " .. key .. " actoin_name: " .. action_name)

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

    log_handler.log_data("=== Default key bindings properly initialized ===")
    log_handler.log_table("current bindings", CurrentBindings)

    apply_bindings()
end

-- Change a single binding (e.g., from settings menu or config file)
local function bind_action(action_name, new_key)
    local previous_binding = table_helper.findKeyForValue(CurrentBindings, new_key)
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
