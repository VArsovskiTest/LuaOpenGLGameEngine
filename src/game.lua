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
local scene_sampler = require("helpers.scene_sampler")
local game_state = require("game_state")

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

-- Invoke once per period/second, not once per frame (i.e. call from C# on timer)
function tick_all_resource_bars()
    local actors = current_scene.actors
    for _, actor in ipairs(actors) do
        safe_call(function()
            if actor.type and actor.type == "resource_bar" and actor.tick then
                log_handler.log_data(tostring(actor.id) .. " ticked")
                actor:tick()
            end
        end)
    end
end

-- # endregion

local function update_scene(gameState)
    local entity_id = gameState.CurrentActor.entity_id
    local dt             = gameState and gameState.dt or 0
    local selected_actor = game_state.find_selected_actor(entity_id)

    log_handler.log_data("entity_id: " .. tostring(entity_id))
    local input_command  = Keyboard.get_current_command()   -- returns nil if no command this frame

    if not input_command then
        CommandQueue:process_next(_G.MockEngine)   -- still drain the queue if there are delayed commands
        return
    end

    if not selected_actor or not selected_actor.Id then
        log_handler.log_data("No selected actor → ignoring input command")
        CommandQueue:process_next(_G.MockEngine)
        return
    end

    local entity = game_state.ensure_entity_exists(selected_actor.Id, selected_actor)
    log_handler.log_table("entity", entity)

    local command = create_command_from_input(
        input_command,
        entity.Id,                -- ← the real GUID
        selected_actor            -- optional: pass more context if needed
    )

    if command then
        CommandQueue:enqueue(command)
    end

    CommandQueue:process_next(_G.MockEngine)
end

function game_tick(gameState)
    log_handler.log_data("game_tick: gameState")
    log_handler.log_table("game_tick: gameState", gameState)
    log_handler.safe_call(function()
        if Keyboard.update then
            Keyboard.update(gameState) -- ← pass gameState if it needs dt, mouse, etc.
        end

        update_scene(gameState)
    end)
end

function initEngine() -- Initialize from Engine (not for Tests)
    local engine = require("engines.mock_command_engine")
    engine:subscribe("enqueue", function(c)
        log_handler.log_data("command issued: ".. tostring(c))
    end)
    engine:subscribe("execute_immediately", function(c)
        log_handler.log_data("command executed: ".. tostring(c))
    end)

    _G.MockEngine = engine

    entity = _G.MockEngine:CreateEntity("entities", "AttackActions")
    entity = _G.MockEngine:CreateEntity("entities", "PositionCommands")

    log_handler.log_data("=== Game: Initialized with Command Mock Engine. ===")
end

function initGame()
    local ok, result_or_err = log_handler.safe_call(function()
        render_scene()
    end)

    if ok then return result_or_err end
end

function game_tick(gameState) -- This tracks User interaction from C# and Actors in GameState
    -- log_handler.log_table("gameState", gameState)
    log_handler.safe_call(function()
        if Keyboard.update then
            Keyboard.update(gameState)
        end
        update_scene(gameState)
    end)
end

game = {
    init_logging = log_handler.init_logging,
    init_error_logging = log_handler.init_error_logging,
    log_data = log_handler.log_data,
    log_error = log_handler.log_error,
    setup_command_queue = setup_command_queue,
    render_scene_with_params = render_scene_with_params,
    render_scene = render_scene,
    find_actor_by_id = game_state.find_actor_by_id,
    find_selected_actor = game_state.find_selected_actor,
    select_actor_by_id = game_state.select_actor_by_id,
    move_actor_by_id = game_state.move_actor_by_id,
    update_actor_by_id = game_state.update_actor_by_id,
    get_current_scene = get_current_scene,
    game_tick = game_tick,
    tick_all_resource_bars = tick_all_resource_bars
}

return game
