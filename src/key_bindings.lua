local Keyboard = require("keyboard")
local ActorActions = require("actor_actions")
local table_helper = require("table_helper")
local log_handler = require("log_handler")

local DefaultBindings = {
    move_up = "w",
    move_down = "s",
    move_left = "a",
    move_right = "d",
    jump = "j",
    attack = "k",
    attack_alt = "l",
    defend = "u",
    sprint = "shift",
    boost = "alt",
    map = "tab",
    use_consumable = "q",
    engage = "e",
    swap_main_attack = "g",
    swap_alt_attack = "h",
    select_1 = "1",
    select_2 = "2",
    select_3 = "3",
    select_4 = "4",
    select_5 = "5",
    select_6 = "6",
    select_7 = "7",
    select_8 = "8",
    select_9 = "9",
    select_0 = "0",
}


CommandMappings = {
    move_up = ActorActions.handle_move_up,
    move_down = ActorActions.handle_move_down,
    move_left = ActorActions.handle_move_left,
    move_right = ActorActions.handle_move_right,
    use_consumable = ActorActions.handle_use_consumable,
    jump = ActorActions.handle_jump,
    attack = ActorActions.handle_attack,
    attack_alt = ActorActions.handle_attack_alt,
    defend = ActorActions.handle_defend,
    sprint = ActorActions.handle_sprint,
    boost = ActorActions.handle_boost,
    map = ActorActions.handle_map,
    engage = ActorActions.handle_engage,
    swap_main_attack = ActorActions.handle_swap_main_attack,
    swap_alt_attack = ActorActions.handle_swap_alt_attack,
    select_1 = ActorActions.handle_select_1,
    select_2 = ActorActions.handle_select_2,
    select_3 = ActorActions.handle_select_3,
    select_4 = ActorActions.handle_select_4,
    select_5 = ActorActions.handle_select_5,
    select_6 = ActorActions.handle_select_6,
    select_7 = ActorActions.handle_select_7,
    select_8 = ActorActions.handle_select_8,
    select_9 = ActorActions.handle_select_9,
    select_0 = ActorActions.handle_select_0,
}

local CurrentBindings = {} -- Format is: [action] = "key"

local function apply_bindings()
    Keyboard.onPress = {}  -- careful: better to just overwrite, this won't work with multiple bindings (i.e. multiplayer)

    for action_name, key in pairs(CurrentBindings) do
        local handler = CommandMappings[action_name]
        if handler then
            Keyboard.bind(key, handler)
        else
            log_handler.log_warn("No handler for action " .. action_name)
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
    if CommandMappings[action_name] then
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

function get_current_command()
    if Keyboard.currentKey then
        for action, key in pairs(CurrentBindings) do
            if key == Keyboard.currentKey then
                log_handler.log_data("found action for key: " .. key .. ", action: "  .. action)
                return action
            end
        end
    end
    return nil
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
    get_current_command = get_current_command,
    get_key_for_action = get_key_for_action,
    apply_bindings = apply_bindings,
    DefaultBindings = DefaultBindings,
    CurrentBindings = CurrentBindings,
    CommandMappings = CommandMappings
}
