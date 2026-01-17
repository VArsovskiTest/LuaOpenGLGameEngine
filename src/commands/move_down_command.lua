-- commands/move_down_command.lua
-- local BaseCommand = require("commands.base_command")
local MoveToCommand = require("commands.move_to_command")
local command_type_identifier = "Position_Commands"

local MoveDownCommand = {}

function MoveDownCommand:new(entity_id, pos)
    local from_x = pos.x or 0
    local from_y = pos.y or 0

    local target_x = from_x
    local target_y = from_y - (pos.speed or 3)

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos = { x = target_x, y = target_y }
    }

    local self = MoveToCommand:new(entity_id, "MoveDownCommand", params)
    self.class = MoveDownCommand
    self.__index = MoveDownCommand
    setmetatable(self, { __index = MoveDownCommand })
end

function MoveDownCommand:getOrigin() return self.params.initial_pos end
function MoveDownCommand:getTarget() return self.params.target_pos end
function MoveDownCommand:execute(engine)
    MoveToCommand:execute(engine)
end

return MoveDownCommand
