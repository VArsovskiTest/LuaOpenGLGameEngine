-- commands/move_right_command.lua
local BaseCommand = require("commands.base_command")
local command_type_identifier = "Position_Commands"

local MoveRightCommand = {}

function MoveRightCommand.new(entity_id, pos)

    local from_x = pos.x or 0
    local from_y = pos.y or 0

    local target_x = from_x + (pos.speed or 0)
    local target_y = from_y

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos = { x = target_x, y = target_y }
    }

    local self = BaseCommand.new("MoveRightCommand", entity_id, params)
    self.class = MoveRightCommand

    function self:getOrigin() return params.initial_pos end
    function self:getTarget() return params.target_pos end

    return setmetatable(self, { __index = MoveRightCommand })
end

return MoveRightCommand