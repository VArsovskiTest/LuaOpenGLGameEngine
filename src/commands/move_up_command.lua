-- commands/move_up_command.lua
-- local BaseCommand = require("commands.base_command")
local MoveToCommand = require("commands.move_to_command")
local command_type_identifier = "Position_Commands"
local log_handler = require("log_handler")

local MoveUpCommand = {}

function MoveUpCommand:new(entity_id, cmd)
    local from_x = cmd.x or 0
    local from_y = cmd.y or 0

    local target_x = from_x
    local target_y = from_y + (cmd.speed or 3)

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = target_x, y = target_y }
    }

    local self = MoveToCommand:new(entity_id, "MoveUpCommand", params)
    self.class = MoveUpCommand
    self.__index = MoveUpCommand
    return setmetatable(self, { __index = MoveUpCommand })
end

function MoveUpCommand:getOrigin() return self.params.initial_pos end
function MoveUpCommand:getTarget() return self.params.target_pos end

function MoveUpCommand:execute(engine)
    MoveToCommand:execute(engine)
end

function MoveUpCommand:undo(engine)
    if self.from then
        local pos_comp = engine:GetComponent(self.entity_id, "Position")
        pos_comp.x = self.from.x
        pos_comp.y = self.from.y
    end
end

return MoveUpCommand
