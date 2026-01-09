-- src/game.lua
local setup = require("src.setup.setup_paths")
setup.setup_paths()

-- Polyfill for older Lua versions
if not math.clamp then
    function math.clamp(value, min, max)
        return math.min(math.max(value, min), max)
    end
end

local color_pallette = require("enums.color_pallette")
local table_helper = require("helpers.table_helper")
local scene_sampler = require("helpers.scene_sampler")

local Clear = require("models.clear")
local Rectangle = require("models.rectangle")
local Circle = require("models.circle")
local ResourceBar = require("models.resource_bar")
local Keyboard = require("keyboard")
local KeyBindings = require("key_bindings")
local CommandQueue = require("commands.command_queue")

local log_handler = require("log_handler")

local function setup_command_queue()
    log_handler.log_data("=== Redis Queue Test Start ===")
    redis_clear("test:queue")

    redis_enqueue("test:queue", { action = "spawn", entity = "enemy", id = 1 })
    redis_enqueue("test:queue", { action = "move", target = "player", x = 100, y = 200 })
    redis_enqueue("test:queue", { action = "attack", damage = 50 })

    log_handler.log_data("Enqueued 3 commands")

    local cmd1 = redis_dequeue("test:queue", 0)
    if cmd1 then
        log_handler.log_data("Dequeued:", cmd1.action, cmd1.entity or cmd1.target or cmd1.damage)
    else
        log_handler.log_data("No command (should not happen)")
    end

    local cmd2 = redis_dequeue("test:queue", 2)
    if cmd2 then
        log_handler.log_data("Dequeued (blocking):", cmd2.action)
    else
        log_handler.log_data("Timeout - no more commands")
    end

    log_handler.log_data("=== Redis Queue Test End ===")
    log_handler.log_data("Executing script: game")
end

-- # region Scene generation

local function clear_current_scene()
    for k in pairs(current_scene) do
        current_scene[k] = nil
    end
    -- or simply: current_scene = {}
end

local function render_scene_with_params(clearColors, actors)
    clear_current_scene()
    return { clears = clearColors, actors = actors }
end

-- Public functions (for Binding with GameEngine in C#)
function render_scene()
    local ok, render_scene_or_error = log_handler.safe_call_with_retry(function()
        local scene = scene_sampler.render_sample_scene()

        current_scene = render_scene_with_params(scene.clears, scene.actors)
        assert_safe(scene ~= nil, "ERROR: failed generating initial scene")
        return current_scene
    end, 5, 250)

    if ok then
        return render_scene_or_error  -- success: scene
    else
        -- Error already printed by global_error_handler
        -- You could add extra handling here if needed
        log_handler.log_error(render_scene_or_error)
        return nil  -- or fallback scene
    end
end

function tick_all_resource_bars()
    local actors = current_scene.actors
    for _, actor in ipairs(actors) do
        safe_call(function()
            if actor.class == ResourceBar and actor.tick then
                actor:tick()
            end
        end)
    end
end

-- # endregion

local function find_actor_by_id(id)
    return table_helper.selectRecordById(current_scene.actors or {}, id)
end

local function update_actor_by_id(id, prop, value)
    table_helper.updateRecordById(current_scene.actors or {}, id, prop, value)
end

local function action_select_actor_by_id(id, value)
    local selected_actor = find_actor_by_id(id)
    if selected_actor then
        update_actor_by_id(id, "selected", value)
        return true
    end

    return false
end

local function action_move_actor_by_id(id, direction, speed)
    speed = speed or 1
    local delta = speed / 100  -- convert to normalized units

    local actor = find_actor_by_id(id)
    if not actor then
        return false
    end

    -- Map direction to coordinate change
    local dir = string.lower(direction)
    local dx, dy = 0, 0
    if dir == "up" then
        dy = delta
    elseif dir == "down" then
        dy = -delta
    elseif dir == "left" then
        dx = -delta
    elseif dir == "right" then
        dx = delta
    else
        -- Optional: warn or ignore invalid direction
        print("Warning: Invalid direction '" .. tostring(direction) .. "' for move_actor_by_id")
        return false
    end

    -- Clamp to [-1, 1] range and update
    if dx ~= 0 then
        local new_x = math.clamp(actor.x + dx, -1, 1)
        update_actor_by_id(id, "x", new_x)
    end

    if dy ~= 0 then
        local new_y = math.clamp(actor.y + dy, -1, 1)
        update_actor_by_id(id, "y", new_y)
    end

    return true
end

local function get_current_scene()
    return current_scene
end

local function update_scene(dt)
    -- do game-state updates (for current_state) logic here later
    Keyboard.update()           -- ← detects presses → calls handlers → enqueues commands
    CommandQueue.process()      -- ← THIS executes the commands!

    -- Then other systems (regen, AI, etc.)
    ResourceSystem.tick()
end

current_scene = current_scene or {}

function initGame()
    log_handler.init_error_logging()
    -- if set_queue setup_command_queue() end

    return render_scene()
end

function game_tick(keyboardState)
    -- Update keyboard table from C# state -- check existence of method to prevent Lua test crash
    if Keyboard_update_from_csharp then Keyboard_update_from_csharp(keyboardState) end
    -- Press detection & callbacks
    Keyboard.update()

    -- Then do resource regen, etc.
    ResourceBar:tick()
end

game = {
    init_logging = log_handler.init_logging,
    init_error_logging = log_handler.init_error_logging,
    log_data = log_handler.log_data,
    log_error = log_handler.log_error,
    setup_command_queue = setup_command_queue,
    render_scene_with_params = render_scene_with_params,
    render_scene = render_scene,
    find_actor_by_id = find_actor_by_id,
    select_actor_by_id = action_select_actor_by_id,
    move_actor_by_id = action_move_actor_by_id,
    get_current_scene = get_current_scene,
    game_tick = game_tick,
    tick_all_resource_bars = tick_all_resource_bars
}

return game
