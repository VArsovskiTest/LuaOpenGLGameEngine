-- src/game.lua
local logPath = get_logs_path("game_engine_log.txt")  -- Just to test the binding
local logFile = nil

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

function log(msg)
    if not logFile then return end
    logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. tostring(msg) .. "\n")
    logFile:flush()
end

local function clear_render_table()
    for k in pairs(render) do
        render[k] = nil
    end
    -- or simply: render = {}
end

function update(dt)
    -- you can do game logic here later
end

render = render or {}

function render_scene()
    clear_render_table()

    table.insert(render, { type = "clear", r = 0.1, g = 0.15, b = 0.3 })

    local time = os.clock()
    local x = math.sin(time * 2) * 0.5

    table.insert(render, {
        type = "rect",
        x = x - 0.2,
        y = -0.3,
        w = 0.4,
        h = 0.6,
        r = 1, g = 0.3, b = 0.5
    })

    table.insert(render, {
        type = "rect",
        x = -0.8, y = -0.8,
        w = 0.3, h = 0.3,
        r = 0.8, g = 0.9, b = 0.2
    })

    return render
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

-- function redis_clear(queue)
--     log("=== Redis Queue: " .. queue .. " Cleared ===")
-- end

-- function redis_enqueue(queue, data)
--     log("=== Redis Queue: " .. queue .. " Added item " .. serialize_table(data) .. " ===")
-- end

-- function redis_dequeue(queue, data)
--     log("=== Redis Queue: " .. queue .. " Removed item " .. serialize_table(data) .. " ===")
-- end

function initGame()
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

    return render_scene()
end
