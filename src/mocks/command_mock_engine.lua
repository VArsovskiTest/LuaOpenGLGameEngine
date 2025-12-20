-- engine/mock_command_engine.lua

local MockCommandEngine = {
    tables = {},
    calls = {},
    next_id = {},
}

-- Initialize a new storage table if it doesn't exist
local function get_or_create_table(name)
    if not MockCommandEngine.tables[name] then
        MockCommandEngine.tables[name] = {}
        MockCommandEngine.calls[name] = {}
        MockCommandEngine.next_id[name] = 1
    end
    return MockCommandEngine.tables[name], MockCommandEngine.calls[name]
end

-- Create a new entity/command with automatic unique ID
function MockCommandEngine:CreateEntity(table_name, commmand_log_name, overrides)
    table_name = table_name or "default"
    local history_log_identifier = commmand_log_name or table_name

    local storage, calls_log = get_or_create_table(history_log_identifier)
    local next_id = MockCommandEngine.next_id[history_log_identifier]

    local entity = {
        id = next_id,
        -- Default fields — customize as needed
        type = "command",
        executed = false,
        payload = {},
    }

    if overrides then
        for k, v in pairs(overrides) do
            entity[k] = v
        end
    end

    storage[next_id] = entity
    MockCommandEngine.next_id[table_name] = next_id + 1

    --table.insert(calls_log, { action = "create", id = next_id, data = entity })
    return entity
end

function MockCommandEngine:AddComponent(entity_id, table_name, component_name, data)
    local entity = self:Get(table_name, entity_id)
    if not entity then error("Entity not found") end

    entity[component_name] = data or {}
    --table.insert(self.calls[table_name], { action = "add_component", entity_id = entity_id, component = component_name })
end

function MockCommandEngine:GetComponent(entity_id, command_type_identifier, component_name)
    return self:Get(command_type_identifier, entity_id)[component_name]
end

-- Get entity/command by ID
function MockCommandEngine:Get(table_name, id)
    table_name = table_name or "default"
    local storage = self.tables[table_name]
    if not storage then
        error("MockCommandEngine: table '" .. table_name .. "' does not exist")
    end
    return storage[id]
end

-- Get all calls/spies for a table
function MockCommandEngine:GetCalls(table_name)
    table_name = table_name or "default"
    return self.calls[table_name] or {}
end

-- Clear everything (great for before_each)
function MockCommandEngine:Reset(table_name)
    if table_name then
        self.tables[table_name] = nil
        self.calls[table_name] = nil
        self.next_id[table_name] = nil
    else
        self.tables = {}
        self.calls = {}
        self.next_id = {}
    end
end

-- Optional: Clear just one table
function MockCommandEngine:ClearTable(table_name)
    self.tables[table_name] = nil
    self.calls[table_name] = nil
    self.next_id[table_name] = nil
end

return MockCommandEngine
