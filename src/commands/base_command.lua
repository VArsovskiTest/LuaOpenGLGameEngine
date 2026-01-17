-- commands/base_command.lua
local BaseCommand = {}

function BaseCommand:new(entity_id, type, params)    
    local self = {
        type = type,
        entity_id = entity_id,
        params = params or {},
        timestamp = os.time(),
        executed = false,
        reverted = false,
    }

    local mt = {
        __index = BaseCommand
    }
    setmetatable(self, mt)
    
    return self
end

-- Default execute method (override per command type)
function BaseCommand:execute(engine)
    print("Executing " .. tostring(self.type) .. " for entity " .. tostring(self.entity_id))
    self.executed = true
end

-- Optional: undo method for reversible commands
function BaseCommand:undo(engine)
    print("Undoing " .. tostring(self.type) .. " for entity " .. tostring(self.entity_id))
    self.reverted = true
end

return BaseCommand
