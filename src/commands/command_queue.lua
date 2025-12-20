-- engine/command_queue.lua

local CommandQueue = {
    queue = {},
    history = {},
    max_history = 200
}

function CommandQueue:enqueue(cmd)
    if cmd then
        table.insert(self.queue, cmd)
    end
end

-- Execute a command immediately and log it (bypasses the queue entirely)
function CommandQueue:execute_immediately(cmd, engine)
    if cmd and engine then
        cmd:execute(engine)
        table.insert(self.history, cmd)
        self:trim_history()
    end
end

-- Process and execute the next command in the queue (FIFO order) and return
function CommandQueue:process_next(engine)
    if #self.queue == 0 or not engine then
        return nil
    end

    local cmd = table.remove(self.queue, 1)  -- Dequeue
    cmd:execute(engine)
    table.insert(self.history, cmd)
    self:trim_history()

    return cmd
end

function CommandQueue:process_all(engine)
    if not engine then return end

    while #self.queue > 0 do
        self:process_next(engine)
    end
end

function CommandQueue:trim_history()
    if #self.history > self.max_history then
        table.remove(self.history, 1)  -- Remove oldest
    end
end

function CommandQueue:clear()
    self.queue = {}
    self.history = {}
end

-- Query: get all executed commands of a specific type
function CommandQueue:get_history_by_type(type_name)
    local filtered = {}
    for _, cmd in ipairs(self.history) do
        if cmd.type == type_name then
            table.insert(filtered, cmd)
        end
    end
    return filtered
end

-- Optional: peek at queue size or next command without processing
function CommandQueue:get_queue_size()
    return #self.queue
end

function CommandQueue:peek_next()
    return self.queue[1]
end

return CommandQueue
