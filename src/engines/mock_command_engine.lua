-- engine/mock_command_engine.lua
local log_handler = require("log_handler")

local MockCommandEngine = {
    tables = {},
    calls = {},
    events = {},
    next_id = {},
}

-- Initialize a new storage table if it doesn't exist
local function get_or_create_table(name)
    if not MockCommandEngine.tables[name] then
        MockCommandEngine.tables[name] = {}
        MockCommandEngine.calls[name] = {}
        -- MockCommandEngine.next_id[name] = 1
    end
    return MockCommandEngine.tables[name], MockCommandEngine.calls[name]
end

-- Create a new entity/command with automatic unique ID
function MockCommandEngine:CreateEntity(table_name, command_log_name, overrides)
    -- table_name = table_name or "default"
    local history_log_identifier = command_log_name or table_name

    log_handler.log_data("creating storage for: " .. history_log_identifier)
    local storage, calls_log = get_or_create_table(history_log_identifier)

    local id
    if overrides and overrides.entity_id then
        id = overrides.entity_id                      -- ← prefer the GUID coming from the command
    elseif overrides and overrides.id then
        id = overrides.id                             -- fallback if someone passes .id instead
    else
        -- only auto-generate if nothing was provided (for pure mock/test cases)
        id = self.next_id[history_log_identifier] or 1
        self.next_id[history_log_identifier] = id + 1
    end

    if storage[id] then
        log_handler.log_error(string.format("CreateEntity: collision on ID %s in %s", tostring(id), history_log_identifier))
        -- error("Entity ID already exists: " .. tostring(id))
        return storage[id]
    end

    local entity = {
        id       = id,          -- store the GUID / key we actually used
        type     = "command",
        executed = false,
        payload  = {},
        metadata = {}
    }

    -- Apply all overrides (including params, command_name, etc.)
    if overrides then
        for k, v in pairs(overrides) do
            entity[k] = v
        end
    end

    storage[id] = entity
    log_handler.log_data(string.format("Created entity with real ID: %s in %s", tostring(id), history_log_identifier))
    return entity
end

function MockCommandEngine:AddComponent(entity_id, table_name, component_name, data)
    -- TODO: must do it this way, either I keep one table/entity in DB ("Commands") and change all Tests or do it this way
    local entity = self:Get(table_name, entity_id)
    if not (entity or {payload = nil}).payload[component_name] then
        local storage, calls_log = self:CreateEntity(entity_id, table_name)
        log_handler.log_data("created storage for: " .. tostring(table_name))
    end

    if not entity then error("Entity not found") end
    entity.payload[component_name] = data or {}
end

function MockCommandEngine:AddMetadata(entity_id, table_name, data)
    local entity = self:Get(table_name, entity_id)
    if not entity then error("Entity for metadata not found") end
    entity.metadata = data or {}
end

function MockCommandEngine:UpdateComponent(entity_id, table_name, component_name, updater)
    local entity = self:Get(table_name, entity_id)
    if not entity then 
        log_handler.log_error("Entity not found for update: " .. tostring(entity_id))
        error("Entity not found")
        return 
    end
    
    local current = entity.payload[component_name]
    if current == nil then -- If doesn't exist yet → initialize as empty table
        current = {}
        entity.payload[component_name] = current
    end
    
    -- Apply the update
    local result = updater(current)
    
    -- If updater returned a new value/table → overwrite
    if result ~= nil and result ~= current then entity.payload[component_name] = result end
    
    -- Optional: log the new state
    -- log_handler.log_table("Updated component " .. component_name, entity.payload[component_name])
end

function MockCommandEngine:UpdateMetadata(entity_id, table_name, updater)
    local entity = self:Get(table_name, entity_id)
    if not entity then
        log_handler.log_error("Entity not found for metadata update: " .. tostring(entity_id))
        error("Entity not found for metadata")
        return 
    end
    
    local current = entity.metadata
    if current == nil then -- If doesn't exist yet → initialize as empty table
        current = {}
        entity.metadata = current
    end
    
    -- Apply the update
    local result = updater(current)
    
    -- If updater returned a new value/table → overwrite
    if result ~= nil and result ~= current then entity.metadata = result end
    
    -- Optional: log the new state
    -- log_handler.log_table("Updated metadata for " .. tostring(entity_id))
end

function MockCommandEngine:GetComponent(entity_id, identifier, component_name)
    local entity = self:Get(identifier, entity_id)
    return entity.payload[component_name]
end

-- Subscribe a handler to an event
function MockCommandEngine:subscribe(event_name, handler_fn)
    if not self.events[event_name] then
        self.events[event_name] = {}
    end
    table.insert(self.events[event_name], handler_fn)
end

-- Unsubscribe (optional, for cleanup)
function MockCommandEngine:unsubscribe(event_name, handler_fn)
    if self.events[event_name] then
        for i, fn in ipairs(self.events[event_name]) do
            if fn == handler_fn then
                table.remove(self.events[event_name], i)
                break
            end
        end
    end
end

-- Fire an event with optional data
function MockCommandEngine:dispatch(event_name, data)
    data = data or {}
    if self.events[event_name] then
        for _, handler in ipairs(self.events[event_name]) do
            handler(data)
        end
    end
end

-- Get entity/command by ID
function MockCommandEngine:Get(table_name, id)
    table_name = table_name or "default"
    local storage = self.tables[table_name]

    if not storage then error("MockCommandEngine: table '" .. table_name .. "' does not exist") end
    return storage[id]
end

-- Get all calls/spies for a table
function MockCommandEngine:GetCalls(table_name)
    table_name = table_name or "default"
    return self.calls[table_name] or {}
end

function MockCommandEngine:Reset(table_name)
    if table_name then
        self.tables[table_name] = nil
        self.calls[table_name] = nil
        self.next_id[table_name] = nil
        self.events[table_name] = nil
    else
        self.tables = {}
        self.calls = {}
        self.next_id = {}
        self.events = {}
    end
end

-- Optional: Clear just one table
function MockCommandEngine:ClearTable(table_name)
    self.tables[table_name] = nil
    self.calls[table_name] = nil
    self.next_id[table_name] = nil
    self.events[table_name] = nil
end

return MockCommandEngine
