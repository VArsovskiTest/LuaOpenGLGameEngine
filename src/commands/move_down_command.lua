-- commands/move_down_command.lua
local BaseCommand = require("commands.base_command")
local command_type_identifier = "Position_Commands"

local MoveDownCommand = {}

function MoveDownCommand:new(entity_id, pos)
    local from_x = pos.x or 0
    local from_y = pos.y or 0

    local target_x = from_x
    local target_y = from_y - (pos.speed or 0)

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos = { x = target_x, y = target_y }
    }

    local self = BaseCommand.new("MoveDownCommand", entity_id, params)
    self.class = MoveDownCommand

    function MoveDownCommand:getOrigin() return params.initial_pos end
    function MoveDownCommand:getTarget() return params.target_pos end

    setmetatable(self, { __index = MoveDownCommand })
end
