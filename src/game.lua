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

-- CommandState = CommandState or {} -- This tracks User interaction from C# and Actors in GameState

local function clear_current_scene()
    local current_scene = game_state.state.current_scene
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
function render_scene(scene_id)
    local ok, result = log_handler.safe_call_with_retry(function()
        -- Generate or load the scene data
        local scene_data = scene_sampler.render_sample_scene()
        assert(scene_data ~= nil, "Failed to generate scene data")

        -- Add actors to current_scene
        game_state.add_actors(render_scene_with_params(
            scene_data.clears or {},
            scene_data.actors or {}
        ))

        local current_scene = game_state.state.current_scene

        -- Ensure EVERY actor in the freshly rendered scene is registered
        for _, actor in ipairs(current_scene.actors or {}) do
            if actor.entity_id then
                game_state.ensure_actor_registered(
                    actor.entity_id,
                    actor   -- pass the whole actor table as hint
                )
            else
                log_handler.log_warn("Actor missing entity_id → skipping registration")
            end
        end

        log_handler.log_data("Scene rendered & " .. #current_scene.actors .. " actors registered")
        return current_scene
    end, 5, 250)

    if ok then
        return result
    else
        log_handler.log_error("render_scene failed: " .. tostring(result))
        return nil   -- or return a fallback/empty scene if you prefer
    end
end

local function update_scene(gameState)
    local dt = gameState.dt or 0

    local cmd_name = KeyBindings.get_current_command()
    local handler = Keyboard.get_current_command_handler()

    if not handler then
        CommandQueue:process_next(_G.MockEngine)
        return
    end

    -- (gameStateTable["CurrentActor"] as LuaTable)["ActorId"]
    local entity_id = gameState.CurrentActor.ActorId
    local selected_actor = game_state.find_actor_by_id(entity_id)
    if selected_actor then
        log_handler.log_table("selected_actor", selected_actor)
    end

    if not selected_actor then
        -- log_handler.log_data("No selected actor → ignoring input")
        CommandQueue:process_next(_G.MockEngine)
        return
    end

    -- Safety net: make sure engine knows about this entity
    local entity_guid = game_state.ensure_actor_registered(
        selected_actor.id,    -- or selected_actor.Id — pick the correct field
        selected_actor
    )

    -- Optional: you can now use entity_guid if needed
    -- (though usually selected_actor.entity_id is already correct)

    local state = {
        entity_id = selected_actor.id,
        from_x    = selected_actor.x,
        from_y    = selected_actor.y,
        speed     = selected_actor.move_speed or 3,
    }

    local mappedCommand = KeyBindings.CommandMappings[cmd_name]

    if not mappedCommand then
        log_handler.log_data("Unknown command type: " .. tostring(handler))
        CommandQueue:process_next(_G.MockEngine)
        return
    end

    log_handler.log_table("Command generated", state)
    local command = mappedCommand(selected_actor.entity_id, state)

    if command then
        CommandQueue:enqueue(selected_actor.entity_id, {
            name    = cmd_type,
            command = command
        })
    end

    CommandQueue:process_next(_G.MockEngine)
end

function game_tick(gameState)
    log_handler.safe_call(function()
        if Keyboard.update then
            Keyboard.update(gameState) -- ← pass gameState if it needs dt, mouse, etc.
        end

        update_scene(gameState)
    end)
end

-- Invoke once per period/second, not once per frame (i.e. call from C# on timer)
function tick_all_resource_bars()
    local current_scene = game_state.state.current_scenea
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

local ENTITY_BUCKET     = "entities"
local LIFECYCLE_LOG     = "EntityLifecycle"   -- or "Lifecycle" or "Actors"

function initEngine()
    local engine = require("engines.mock_command_engine")
    
    engine:subscribe("enqueue", function(c)
        log_handler.log_data("command enqueued: " .. tostring(c))
    end)
    
    engine:subscribe("execute_immediately", function(c)
        log_handler.log_data("command executed: " .. tostring(c))
    end)
    
    _G.MockEngine = engine
    -- TODO: figure out why without this the storage initializations don't work..
    _G.MockEngine:CreateEntity(ENTITY_BUCKET, LIFECYCLE_LOG)
    log_handler.log_data("=== Game: Initialized with Command Mock Engine. ===")
end

function initGame()
    game_state.state.current_scene = game_state.state.current_scene or {}
    local ok, result_or_err = log_handler.safe_call(function()
        Keyboard.init()
        KeyBindings.bind_defaults()
        KeyBindings.apply_bindings()
        render_scene()
    end)

    if ok then return result_or_err end
end

game = {
    current_scene = game_state.state.current_scene,
    find_actor_by_id = game_state.find_actor_by_id,
    find_selected_actor = game_state.find_selected_actor,
    get_current_scene = get_current_scene,
    game_tick = game_tick,
    init_logging = log_handler.init_logging,
    init_error_logging = log_handler.init_error_logging,
    move_actor_by_id = game_state.move_actor_by_id,
    log_data = log_handler.log_data,
    log_error = log_handler.log_error,
    render_scene_with_params = render_scene_with_params,
    render_scene = render_scene,
    setup_command_queue = setup_command_queue,
    select_actor_by_id = game_state.select_actor_by_id,
    tick_all_resource_bars = tick_all_resource_bars,
    update_actor_by_id = game_state.update_actor_by_id,
}

return game
