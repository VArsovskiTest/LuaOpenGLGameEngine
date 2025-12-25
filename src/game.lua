-- src/game.lua
local setup = require("src.setup.setup_paths")
setup.setup_paths()

local guid_generator = require("helpers.guid_helper")

local enableLogging = true  -- Set to false to skip logging

local logPath

if get_logs_path and enableLogging then
    logPath = get_logs_path("game_engine_log.txt")
end

local logFile = nil

local color_helper = require("helpers/color_helper")
local color_pallette = require("enums/colors")
local ColorHelper = color_helper:new()

local function log(msg)
    if not logFile then return end
    logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. tostring(msg) .. "\n")
    logFile:flush()
end

local function clear_current_scene()
    for k in pairs(current_scene) do
        current_scene[k] = nil
    end
    -- or simply: current_scene = {}
end

local function generate_actor_data(type, actor)
    local actor_data = {}

    if type == "rect" then
        actor_data = {
            x = actor.x or 0,
            y = actor.y or 0,
            width = actor.width or 0.1,
            height = actor.height or 0.1,
        }

    elseif type == "resource_bar" then
        actor_data = {
            name = actor.name or "unnamed_bar",
            current = actor:current() or 0,
            maximum = actor:maximum() or 100,
            percentage = actor:percentage() or 0,
            x = actor.x or 0,
            y = actor.y or 0,
        }

    elseif type == "circle" then
        actor_data = {
            id = guid_generator.generate_guid(),
            x = actor.x or 0,
            y = actor.y or 0,
            rad = actor.rad or 0.1,
        }

    else
        error("game.lua: Unknown actor type '" .. tostring(type) .. "'")
    end

    actor_data.type = type
    return actor_data
end

current_scene = current_scene or {}

function render_scene_with_params(clearColors, actors)
    -- local time = os.clock()
    -- local x = math.sin(time * 2) * 0.5
    -- -- Insert rectangle based on dynamic values
    -- local clr = ColorHelper.createColorObject(clearColor or color_pallette.INDIGO)
    -- table.insert(current_state, {
    --     type = "rect",
    --     x = x - 0.2,
    --     y = -0.3,
    --     w = 0.4,
    --     h = 0.6,
    --     r = clr.r,
    --     g = clr.g,
    --     b = clr.b,
    --     a = clr.a
    -- })

    clear_current_scene()
    local scene = { clears = {}, actors = {} }

    -- Insert clear color based on the passed parameter
    for _, clr in ipairs(clearColors) do
        local colorObject = ColorHelper.createColorObject(clr or color_pallette.RICH_MAGENTA)
        table.insert(scene.clears, {
            type = "clear",
            id = guid_generator.generate_guid(),
            r = colorObject.r,
            g = colorObject.g,
            b = colorObject.b,
            a = colorObject.a,
        })
    end

    -- Insert actors from provided parameters
    for _, actor in ipairs(actors) do
        local actor_type = actor.type
        local actor_data = generate_actor_data(actor_type, actor)

        local selected_color = ({
            rect         = color_pallette.SILVER,
            circle       = color_pallette.TEAL,
            resource_bar = color_pallette.MAGENTA
        })[actor_type] or color_pallette.WHITE
        actor_data.color = ColorHelper.createColorObject(selected_color)

        actor_data.id  = guid_generator.generate_guid()
        table.insert(scene.actors, actor_data)
    end

    current_scene = scene;
    return current_scene
end

-- Helper function to convert a table to a string for logging
local function serialize_table(t)
    if type(t) ~= 'table' then
        return tostring(t)
    end
    local s = '{ '
    for k, v in pairs(t) do
        s = s .. tostring(k) .. '=' .. serialize_table(v) .. ', '
    end
    return s .. '}'
end

local function setup_command_queue()
    log("=== Redis Queue Test Start ===")
    redis_clear("test:queue")

    redis_enqueue("test:queue", { action = "spawn", entity = "enemy", id = 1 })
    redis_enqueue("test:queue", { action = "move", target = "player", x = 100, y = 200 })
    redis_enqueue("test:queue", { action = "attack", damage = 50 })

    log("Enqueued 3 commands")

    local cmd1 = redis_dequeue("test:queue", 0)
    if cmd1 then
        log("Dequeued:", cmd1.action, cmd1.entity or cmd1.target or cmd1.damage)
    else
        log("No command (should not happen)")
    end

    local cmd2 = redis_dequeue("test:queue", 2)
    if cmd2 then
        log("Dequeued (blocking):", cmd2.action)
    else
        log("Timeout - no more commands")
    end

    log("=== Redis Queue Test End ===")
    log("Executing script: game")
end

function render_scene()
    local scene_sampler = require("helpers.scene_sampler")
    local scene = scene_sampler.render_sample_scene()

    -- log(serialize_table(clears))
    -- log(serialize_table(rects))
    -- log(serialize_table(resource_bars))
    -- log(serialize_table(circles))
    
    return render_scene_with_params(scene.clears, scene.actors)
end

-- Public functions (for Binding with GameEngine in C#)
function initGame()
    local scene_sampler = require("helpers.scene_sampler")
    local clears, rects, resource_bars, circles = scene_sampler.render_sample_scene()

    guid_generator.initialize_guid_generation()

    setup_command_queue()
    return render_scene_with_params(clears, rects, resource_bars, circles)
end

function update(dt)
    -- you can do game-state (for current_state) logic here later
end

function init_logging()
    if logFile then return end
    
    local path = get_logs_path("game_engine_log.txt")
    logFile = io.open(path, "a")
    if logFile then
        logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] === Game Session Started ===\n")
        logFile:flush()
        print("Log initialized successfully at: " .. path)
    else
        print("FAILED to open log file: " .. path)
        print("Check permissions and path: " .. path)
    end
end

return {
    setup_command_queue = setup_command_queue,
    render_scene_with_params = render_scene_with_params,
    render_scene = render_scene
}
