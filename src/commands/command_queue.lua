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

-- Private: executes a command, dispatches event, and records in history
function CommandQueue:_execute_and_record(cmd, engine)
    if not cmd or not engine then return end

    cmd:execute(engine)
    _G.MockEngine:dispatch("command_executed", { command = cmd })
    table.insert(self.history, cmd)
    self:trim_history()
end

-- Execute immediately (bypasses queue)
function CommandQueue:execute_immediately(cmd, engine)
    self:_execute_and_record(cmd, engine)
end

-- Process next from queue
function CommandQueue:process_next(engine)
    if #self.queue == 0 or not engine then
        return nil
    end

    local cmd = table.remove(self.queue, 1)
    self:_execute_and_record(cmd, engine)

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
