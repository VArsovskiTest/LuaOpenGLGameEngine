--tests/test_redis.lua

local init = require("../src/tests/test_init")
local Queue = require("engines.redis_command_engine")

-- Simple handler for testing
local function my_handler(cmd)
    print("Processing command:", cmd.action, "with data:", cmd.data)
    if cmd.action == "fail" then
        error("intentional failure")
    end
    -- Simulate work
    -- os.execute("sleep 0.1")
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
local processed = q:process_all(my_handler)
print("Processed", processed, "jobs in drain mode")

-- Or run a continuous worker in a separate script:
-- q:worker(my_handler)  -- blocks forever