-- redis_command_engine.lua
local json = require("dkjson")
local redis = require("redis")

local Queue = {}
Queue.__index = Queue

function Queue:new(config)
    local client = redis.connect(config.host or "127.0.0.1", config.port or 6379)
    
    if config.password then
        client:auth(config.password)
    end
    
    if config.db then
        client:select(config.db)
    end

    local self = setmetatable({
        client = client,
        key = config.key or "my:queue",
    }, Queue)

    return self
end

-- Enqueue a command (any Lua value that can be JSON-encoded)
function Queue:enqueue(command)
    local payload = json.encode({ cmd = command })
    local pushed = self.client:rpush(self.key, payload)
    return pushed > 0
end

-- Dequeue one job (blocking with timeout, or non-blocking if timeout = 0)
-- Returns decoded command table or nil if timeout/empty
function Queue:dequeue(timeout)
    timeout = timeout or 0  -- 0 = non-blocking, >0 = blocking seconds
    local res = self.client:blpop(self.key, timeout)
    
    if not res then
        return nil
    end
    
    local payload = res[2]  -- blpop returns {key, value}
    if not payload then
        return nil
    end

    local job, _, err = json.decode(payload)
    if err then
        print("JSON decode error:", err)
        return nil
    end
    if job.cmd then
        return job.cmd
    end
end

-- Process the next available job with the given handler function
-- handler(cmd) should return true/nil for success or false,error_msg for failure
function Queue:process_next(handler)
    local cmd = self:dequeue(0)  -- non-blocking
    if not cmd then
        return false, "no job"
    end
    
    local ok, err = pcall(handler, cmd)
    if ok then
        return true
    else
        return false, err
    end
end

-- Process all currently queued jobs (non-blocking drain)
function Queue:process_all(handler)
    local count = 0
    while true do
        local ok, err = self:process_next(handler)
        if not ok then
            break  -- queue empty
        end
        count = count + 1
    end
    return count
end

-- Continuous worker loop – blocks forever processing jobs as they arrive
function Queue:worker(handler, poll_timeout)
    poll_timeout = poll_timeout or 5
    print("Worker started on queue:", self.key)
    
    while true do
        local cmd = self:dequeue(poll_timeout)
        if cmd then
            local ok, err = pcall(handler, cmd)
            if ok then
                print("Processed job successfully")
            else
                print("Job failed:", err)
            end
        end
    end
end

return Queue
