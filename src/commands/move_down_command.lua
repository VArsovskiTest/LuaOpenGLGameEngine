-- commands/move_down_command.lua
local MoveToCommand = require("commands.move_to_command")
local log_handler   = require("log_handler")

local command_type_identifier = "PositionCommands"

local MoveDownCommand = {}
MoveDownCommand.super = MoveToCommand

function MoveDownCommand:new(entity_id, cmd)
    local from_x = cmd.x or cmd.from_x or 0
    local from_y = cmd.y or cmd.from_y or 0
    local speed  = cmd.speed or 3

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = from_x, y = from_y + speed },
    }

    local self = MoveToCommand:new(
        entity_id,
        "MoveDownCommand",
        command_type_identifier,
        "Position",
        params
    )
    return self
end

function MoveDownCommand:_call_execute(engine, entry)
    log_handler.log_data("MoveDownCommand:_call_execute → calling MoveToCommand")
    MoveDownCommand.super._call_execute(self, engine, entry)
end

function MoveDownCommand:undo(engine)
    if self.from then
        local pos_comp = engine:GetComponent(self.entity_id, "Position")
        pos_comp.x = self.from.x
        pos_comp.y = self.from.y
    end
end

return MoveDownCommand
