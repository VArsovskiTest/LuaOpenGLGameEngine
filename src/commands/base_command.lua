-- commands/base_command.lua
local log_handler = require("log_handler")

local BaseCommand = {}

function BaseCommand:new(entity_id, command_name, command_queue_name, component_name, params)
    local self = {
        timestamp          = os.time(),
        entity_id          = entity_id,
        command_name       = command_name or "BaseCommand",
        params             = params or {},
        command_queue_name = command_queue_name,
        component_name     = component_name or "Position",
        executed           = false,
        reverted           = false,
        INITIAL_STATE      = nil,   -- we'll set it later - nil means "not fetched yet"
    }

    log_handler.log_data(string.format(
        "BaseCommand:new → %s | entity:%s | queue:%s | comp:%s",
        self.command_name,
        tostring(entity_id),
        tostring(command_queue_name),
        tostring(component_name)
    ))

    setmetatable(self, { __index = BaseCommand })
    return self
end

function BaseCommand:_call_execute(engine)
    local comp = engine:GetComponent(self.entity_id, self.command_queue_name, self.component_name)
    self.INITIAL_STATE = comp or {}

    self:execute(engine)          -- ← also update :execute to take only engine
    self.executed = true
end

function BaseCommand:execute(engine, entry)
    -- This should NEVER be reached in normal operation
    -- Subclasses MUST override this method
    error(string.format(
        "%s must implement :execute(engine, entry) - base version called!",
        self.command_name or "UnnamedCommand"
    ))
end

function BaseCommand:undo(engine)
    if not self.executed then
        log_handler.log_data("Cannot undo - command was not executed")
        return
    end

    log_handler.log_data(string.format("Undo called for %s (entity %s)",
        self.command_name or "<?>",
        tostring(self.entity_id)))

    self.reverted = true
    -- Subclasses should override and implement actual undo logic
end

-- Optional helper for subclasses to call super safely
function BaseCommand:callSuperExecute(engine, entry)
    if BaseCommand.execute == self.execute then
        error("No super execute available - this is the base method")
    end
    BaseCommand.execute(self, engine, entry)
end

return BaseCommand
