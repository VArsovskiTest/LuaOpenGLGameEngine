-- src/game.lua
local setup = require("src.setup.setup_paths")
setup.setup_paths()

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
    for k in pairs(current_state) do
        current_state[k] = nil
    end
    -- or simply: current_state = {}
end

current_state = current_state or {}

function render_scene_with_params(clearColors, rects, resource_bars, circles)
    clear_current_scene()

    -- Insert clear color based on the passed parameter
    for _, clr in ipairs(clearColors) do
        local colorObject = ColorHelper.createColorObject(clr or color_pallette.RICH_MAGENTA)
        table.insert(current_state, {
            type = "clear",
            r = colorObject.r,
            g = colorObject.g,
            b = colorObject.b,
            a = colorObject.a,
        })
    end

    local time = os.clock()
    local x = math.sin(time * 2) * 0.5

    -- Insert rectangle based on dynamic values
    local clr = ColorHelper.createColorObject(clearColor or color_pallette.INDIGO)
    table.insert(current_state, {
        type = "rect",
        x = x - 0.2,
        y = -0.3,
        w = 0.4,
        h = 0.6,
        r = clr.r,
        g = clr.g,
        b = clr.b,
        a = clr.a
    })

    -- Insert additional rectangles from the provided parameter
    for _, rect in ipairs(rects) do
        local clr = ColorHelper.createColorObject(rect.color_id or color_pallette.SILVER)
        table.insert(current_state, {
            type = "rect",
            x = rect.x,
            y = rect.y,
            w = rect.w,
            h = rect.h,
            r = clr.r,
            g = clr.g,
            b = clr.b,
            a = clr.a
        })
    end

    for _, bar in ipairs(resource_bars) do
        local clr = ColorHelper.createColorObject(bar.color_id or color_pallette.GOLD)
        table.insert(current_state, {
            type = "resource_bar",
            name = bar:name() or nil,
            current = bar:current() or 0,
            maximum = bar:maximum() or 100,
            percentage = bar:percentage() or 0,
            r = clr.r,
            g = clr.g,
            b = clr.b,
            a = clr.a,
        })
    end

    for _, c in ipairs(circles) do
        local clr = ColorHelper.createColorObject(c.color_id  or color_pallette.OLIVE)
        table.insert(current_state, {
            type = "circle",
            x = c.x or -2,
            y = c.y or -2,
            r = clr.r,
            g = clr.g,
            b = clr.b,
            a = clr.a,
        })
    end

    return current_state
end

function render_scene()
    local scene_sampler = require("helpers.scene_sampler")
    local clears, rects, resource_bars, circles = scene_sampler.render_sample_scene()
    render_scene_with_params(clears, rects, resource_bars, circles)
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

-- Public functions (for Binding with GameEngine in C#)
function initGame()
    setup_command_queue()
    return render_scene()
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
