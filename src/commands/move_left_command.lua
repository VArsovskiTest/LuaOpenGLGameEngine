-- commands/move_left_command.lua
-- local BaseCommand = require("commands.base_command")
local MoveToCommand = require("commands.move_to_command")
local command_type_identifier = "Position_Commands"

local MoveLeftCommand = {}

function MoveLeftCommand:new(entity_id, pos)
    local from_x = pos.x or 0
    local from_y = pos.y or 0

    local target_x = from_x - (pos.speed or 0)
    local target_y = from_y

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos = { x = target_x, y = target_y }
    }

    local self = MoveToCommand.new("MoveLeftCommand", entity, params)
    self.class = MoveLeftCommand
    self.__index = MoveLeftCommand
    return setmetatable(self, { __index = MoveLeftCommand })
end

function MoveLeftCommand:getOrigin() return self.params.initial_pos end
function MoveLeftCommand:getTarget() return self.params.target_pos end
function MoveLeftCommand:execute(engine)
    log_handler.log_data("MoveLeftCommand executed")
    MoveToCommand:execute(engine)
end

return MoveLeftCommand