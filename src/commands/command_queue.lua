-- engine/command_queue.lua
local log_handler = require("log_handler")

CommandQueue = {
    queue = {},
    history = {},
    max_history = 200
}

-- Enqueue with separate column containing entity_id so can search/filter better later on
function CommandQueue:enqueue(entity_id, cmd)
    if not entity_id or not cmd then return end
    table.insert(self.queue, { entity_id, cmd, "pending" })
end

function CommandQueue:dequeue()
    local entry = table.remove(self.queue, 1)
    if entry then
        entry[3] = "processing"
    end
    return entry
end

function CommandQueue:cleanup()
    for i = #self.queue, 1, -1 do
        local status = self.queue[i][3]
        if status == "done" or status == "failed" then
            table.remove(self.queue, i)
        end
    end
end

function CommandQueue:reset()
    self.queue = {}
    self.history = {}
end

function CommandQueue:trim_history()
    if #self.history > self.max_history then
        table.remove(self.history, 1)  -- Remove oldest
    end
end

function CommandQueue:getByEntityId(entity_id, include_resolved)
    local results = {}
    for _, entry in ipairs(self.queue) do
        if entry[1] == entity_id and (include_resolved or entry[3] == "pending" or entry[3] == "processing") then
            table.insert(results, entry[2])
        end
    end
    return results
end

function CommandQueue:get_next_pending(preserve_status)
    for _, entry in ipairs(self.queue) do
        if entry[3] == "pending" then
            if not preserve_status then entry[3] = "processing" end
            return entry
        end
    end
    return nil
end

function CommandQueue:set_status(id, status)
    for _, entry in ipairs(self.queue) do
        if entry[1] == id then
            entry[3] = status
            return entry
        end
    end
    return nil
end

function CommandQueue:process_one(entry, engine)
    if not entry or not engine then
        log_handler.log_error("process_one: missing entry or engine")
        return false
    end
    local cmd = entry[2]
    if not cmd then
        log_handler.log_error("process_one: entry[2] is nil")
        return false
    end
    local command = cmd.command or cmd
    if type(command) ~= "table" then
        log_handler.log_error("process_one: command is not a table")
        return false
    end
    local cmd_execute = command._call_execute
    if type(cmd_execute) ~= "function" then
        log_handler.log_error("process_one: command has no _call_execute function")
        return false
    end

    entry[3] = "processing"

    -- ────────────────────────────────────────────────
    -- Entity & component setup
    -- ────────────────────────────────────────────────
    local entity_id   = command.entity_id
    local params      = command.params or {}
    local queue_name  = command.command_queue_name or "PositionCommands"   -- fallback

    if not entity_id then
        log_handler.log_error("process_one: command missing entity_id")
        entry[3] = "failed"
        return false
    end

    -- Add the intended position component (initial → target)
    engine:AddComponent(entity_id, queue_name, "Position", params)

    -- ────────────────────────────────────────────────
    -- Execute the command itself (no entry passed)
    -- ────────────────────────────────────────────────
    local success, err = pcall(cmd_execute, command, engine)

    log_handler.log_data("_call_execute success: " .. tostring(success))
    if not success then
        log_handler.log_error("_call_execute error: " .. tostring(err))
    end

    engine:dispatch("command_executed", entry, success, err)

    if success then
        entry[3] = "done"
        table.insert(self.history, entry)
        self:trim_history()
    else
        entry[3] = "failed"
        command.error = tostring(err) or "Unknown error"
    end

    return success, err
end

function CommandQueue:process_next(engine)
    if not engine then return false end

    local entry = self:get_next_pending()
    if entry then
        local entity_id = entry[1]
        local cmd = entry[2]

        self:set_status(entity_id, "processing")
        return self:process_one(entry, engine)
        -- return CommandQueue:resolve(entity_id, success) -- TODO: We don't do automatically Resolve on Process to allow usage of Inheritance
    end
    return false, "Entry not found"
end

-- Does not contain all command data so pass id separately from the wrapper
function CommandQueue:execute_immediately(entity_id, cmd, engine)
    if not entity_id or not cmd or not engine then
        return false, "Missing entity_id, cmd or engine"
    end

    local temp_entry = {
        entity_id,
        cmd,
        "processing"   -- start directly in processing
    }

    local success, err = self:process_one(temp_entry, engine)

    if success then
        local params = cmd.params or {}
        engine:AddComponent(entity_id, "PositionCommands", "Position", params)
    end

    return success, err, temp_entry   -- optional: return entry-like for tests
end

function CommandQueue:process_all(engine)
    local processed = 0
    if not engine then return -1 end

    while #self.queue > 0 do
        local cmd = self:dequeue()
        self:process_one(cmd, engine)
        processed = processed + 1
    end
    return processed
end

function CommandQueue:resolve(entity_id, success)
    for i = #self.queue, 1, -1 do
        local entry = self.queue[i]
        if entry[1] == entity_id and entry[3] == "processing" then
            if success then
                entry[3] = "done"
            else
                entry[3] = "failed"
            end
            return true
        end
    end
    return false
end

function CommandQueue:get_commands_for_entity(entity_id, only_active)
    local results = {}
    for _, entry in ipairs(self.queue) do
        if entry[1] == entity_id then
            if not only_active or 
               (entry[3] == "pending" or entry[3] == "processing") then
                table.insert(results, entry)
            end
        end
    end
    return results
end

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
