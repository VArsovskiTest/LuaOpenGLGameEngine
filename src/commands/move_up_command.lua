-- commands/move_up_command.lua
local MoveToCommand = require("commands.move_to_command")
local log_handler   = require("log_handler")

local command_type_identifier = "PositionCommands"

local MoveUpCommand = {}
MoveUpCommand.super = MoveToCommand

function MoveUpCommand:new(entity_id, cmd) -- Required Params = from_x, from_y, speed
    local from_x = cmd.x or cmd.from_x or 0
    local from_y = cmd.y or cmd.from_y or 0
    local speed  = cmd.speed or 3

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = from_x, y = from_y + speed },
    }

    -- Pass the subclass name so logs/debug show "MoveUpCommand"
    local self = MoveToCommand:new(
        entity_id,
        "MoveUpCommand",
        command_type_identifier,
        "Position",
        params
    )

    -- No need to setmetatable again — we inherit the metatable from MoveToCommand

    return self
end

-- No need to override getOrigin/getTarget — uses parent's

-- No need to override execute — uses MoveToCommand:execute

function MoveUpCommand:_call_execute(engine, entry)
    log_handler.log_data("MoveUpCommand:_call_execute → calling MoveToCommand")
    MoveUpCommand.super._call_execute(self, engine, entry)
end

-- If you ever need special MoveUp logic (rare):
-- function MoveUpCommand:execute(engine, entry)
--     log_handler.log_data("MoveUp extra logic here")
--     MoveUpCommand.super.execute(self, engine, entry)
-- end

function MoveUpCommand:undo(engine)
    if self.from then
        local pos_comp = engine:GetComponent(self.entity_id, "Position")
        pos_comp.x = self.from.x
        pos_comp.y = self.from.y
    end
end

return MoveUpCommand
