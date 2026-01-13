-- engine/command_queue.lua
local log_handler = require("log_handler")

CommandQueue = {
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
function CommandQueue:execute_and_record(cmd, engine)
    if not cmd or not engine then return end

    if cmd.command and cmd.command.execute then
        log_handler.log_table("Inside CommandQueue: execute", cmd)
        cmd.command:execute(engine)
        engine:dispatch("command_executed", cmd)
        table.insert(self.history, cmd)
        self:trim_history()
    end
end

-- Execute immediately (bypasses queue)
function CommandQueue:execute_immediately(cmd, engine)
    self:execute_and_record(cmd, engine)
end

-- Process next from queue
function CommandQueue:process_next(engine)
    if #self.queue == 0 or not engine then
        return nil
    end

    local cmd = table.remove(self.queue, 1)
    self:execute_and_record(cmd, engine)

    -- TODO: Move to command on execution itself ?
    local cmd_name = cmd and cmd.name or "unknown_command"
    local entity_id = cmd and cmd.id or "unknown_id"

    log_handler.log_data("Before AddComponent")
    log_handler.log_data("entity_id: " .. tostring(entity_id or "no_entity"))
    log_handler.log_table("cmd", cmd)
    
    engine.AddComponent(entity_id, "Position_Commands", "Position", { cmd and cmd.params or { { x = 0, y = 0 }, { x = 0, y = 0 } } })
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

function CommandQueue:undo_and_record(cmd, engine)
    if not cmd or not engine then return end

    if cmd.undo then
        cmd:undo(engine)
        engine:dispatch("command_reverted", cmd)
        table.insert(self.history, cmd)
        self:trim_history()
    end
end

function CommandQueue:undo_last(engine)
    if #self.history == 0 or not engine then
        return nil
    end

    local cmd = self.history[#self.history]
    self:undo_and_record(cmd, engine)

    return cmd
end

return CommandQueue
