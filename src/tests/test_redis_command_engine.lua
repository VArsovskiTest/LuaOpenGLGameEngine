--tests/test_redis.lua

local init = require("../src/tests/test_init")
local Queue = require("engines.redis_command_engine")

-- Simple handler for testing
local function my_handler(cmd, delay_ms)
    print("Processing command:", cmd.action, "with data:", cmd.data)
    if cmd.action == "fail" then
        error("intentional failure")
    end
    -- os.execute("sleep " .. delay_ms / 1000)  -- Unix
    os.execute("timeout /t " .. delay_ms / 1000) -- Win
end

-- Create queue instance
local q = Queue:new({
    host = "127.0.0.1",
    port = 6379,
    -- password = "yourpass",
    -- db = 0,
    key = "test:queue"
})

-- Clear any old data
q.client:del(q.key)

-- Enqueue some test jobs
q:enqueue({ action = "greet", data = "world" })
q:enqueue({ action = "add", data = {1, 2} })
q:enqueue({ action = "fail", data = "boom" })
q:enqueue({ action = "done" })

print("Enqueued 4 jobs")

-- Process all current jobs
local processed = q:process_all(my_handler, 500)
print("Processed", processed, "jobs in drain mode")
