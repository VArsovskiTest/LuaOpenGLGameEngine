-- commands/move_right_command.lua
-- local BaseCommand = require("commands.base_command")
local MoveToCommand = require("commands.move_to_command")
local command_type_identifier = "Position_Commands"

local MoveRightCommand = {}

function MoveRightCommand.new(entity_id, pos)
    local from_x = pos.x or 0
    local from_y = pos.y or 0

    local target_x = from_x + (pos.speed or 3)
    local target_y = from_y

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos = { x = target_x, y = target_y }
    }

    local self = MoveToCommand:new(entity_id, "MoveRightCommand", params)
    self.class = MoveRightCommand
    self.__index = MoveRightCommand
    return setmetatable(self, { __index = MoveRightCommand })
end

function MoveRightCommand:getOrigin() return self.params.initial_pos end
function MoveRightCommand:getTarget() return self.params.target_pos end
function MoveRightCommand:execute(engine)
    MoveToCommand:execute(engine)
end

return MoveRightCommand
