-- commands/move_right_command.lua
local MoveToCommand = require("commands.move_to_command")
local log_handler   = require("log_handler")

local command_type_identifier = "PositionCommands"

local MoveRightCommand = {}
MoveRightCommand.super = MoveToCommand

function MoveRightCommand:new(entity_id, cmd)
    local from_x = cmd.x or cmd.from_x or 0
    local from_y = cmd.y or cmd.from_y or 0
    local speed  = cmd.speed or 3

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = from_x + speed, y = from_y },
    }

    -- Pass the subclass name so logs/debug show "MoveRightCommand"
    local self = MoveToCommand:new(
        entity_id,
        "MoveRightCommand",
        command_type_identifier,
        "Position",
        params
    )

    return self
end

function MoveRightCommand:_call_execute(engine, entry)
    log_handler.log_data("MoveRightCommand:_call_execute → calling MoveToCommand")
    MoveRightCommand.super._call_execute(self, engine, entry)
end

function MoveRightCommand:undo(engine)
    if self.from then
        local pos_comp = engine:GetComponent(self.entity_id, "Position")
        pos_comp.x = self.from.x
        pos_comp.y = self.from.y
    end
end

return MoveRightCommand
