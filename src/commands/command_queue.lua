-- engine/command_queue.lua
local log_handler = require("log_handler")

CommandQueue = {
    queue = {},
    history = {},
    max_history = 200
}

function CommandQueue:enqueue(engine, entity_id, cmd_wrapper)
    local cmd = cmd_wrapper.command or cmd_wrapper -- for Tests
    if not cmd or not entity_id then return end

    -- local entry_meta = {
    --     type        = "command",
    --     status      = "pending",
    --     enqueued_at = os.time(),
    --     name        = cmd.command_name or "UnknownCommand",
    --     component   = cmd.component_name or "UnknownComponent",
    --     queue       = cmd.command_queue_name or "UnknownQueue",
    --     params      = cmd.params or {}, -- add more if commands often need them: speed, duration, etc.
    -- }

    engine:AddComponent(
        entity_id,
        cmd.command_queue_name,
        cmd.component_name,
        cmd.params or {}
    )

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
    if not entry or not engine then log_handler.log_error("process_one: missing entry or engine") return false end
    local cmd = entry[2]

    if not cmd then log_handler.log_error("process_one: entry[2] is nil") return false end
    local command = cmd.command or cmd
    log_handler.log_table("Command generated", command)

    if type(command) ~= "table" then log_handler.log_error("process_one: command is not a table") return false end
    local cmd_execute = command._call_execute

    if type(cmd_execute) ~= "function" then log_handler.log_error("process_one: no _call_execute function") return false end

    local entity_id = command.entity_id
    if not entity_id then
        log_handler.log_error("process_one: missing entity_id")
        entry[3] = "failed"
        return false
    end

    local entity_id   = command.entity_id
    local params      = command.params or {}
    local queue_name  = command.command_queue_name or "Commands"   -- fallback
    local component_name = command.component_name or "Data"

    engine:AddMetadata(entity_id, queue_name, { entity_id = entity_id, command_name = cmd.command_name or "UnknownCommand", status = entry[3], started = os.time })

    local success, err = pcall(cmd_execute, command, engine)

    log_handler.log_data("_call_execute success: " .. tostring(success))
    if not success then log_handler.log_error("_call_execute error: " .. tostring(err)) end

    engine:dispatch("command_executed", entry, success, err)

    engine:UpdateMetadata(entity_id, queue_name, function(current)
        local record = current or {}
        if record.command_name == command.command_name then
            record.status     = success and "done" or "failed"
            record.finished   = os.time()
            record.success    = success
            record.error      = success and nil or (tostring(err) or "Unknown error")
        end
        return record
    end)

    if success then
        entry[3] = "done"
        table.insert(self.history, entry)
        self:trim_history()
    else
        entry[3] = "failed"
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
    return false, "process_next: Entry not found"
end

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
        engine:AddMetadata(entity_id, cmd.command_queue_name or "Commands", params)
    end

    return success, err, temp_entry   -- optional: return entry-like for tests
end

-- function CommandQueue:process_all(engine)
--     local processed = 0
--     if not engine then return -1 end

--     while #self.queue > 0 do
--         local cmd = self:dequeue()
--         self:process_one(cmd, engine)
--         processed = processed + 1
--     end
--     return processed
-- end

function CommandQueue:process_next_batch(engine, max_per_frame)
    local max_n = max_per_frame or 8 -- set default max commands per frame here
    local processed = 0

    while #self.queue > 0 and processed < max_n do
        local entry = self:dequeue()
        if entry then
            self:process_one(entry, engine)
            processed = processed + 1
        else
            break
        end
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
