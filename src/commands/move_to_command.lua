-- commands/move_to_command.lua
local BaseCommand = require("commands.base_command")
local command_type_identifier = "Position_Commands"

local MoveToCommand = {}

function MoveToCommand.new(entity_id, pos)
    local from_x = pos.from_x or 0
    local from_y = pos.from_y or 0

    local target_x = pos.to_x ~= nil and pos.to_x or from_x
    local target_y = pos.to_y ~= nil and pos.to_y or from_y

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = target_x, y = target_y }
    }

    local self = BaseCommand.new("MoveToCommand", entity_id, params)

    function self:getFrom() return self.params.initial_pos end
    function self:getTarget() return self.params.target_pos end

    return setmetatable(self, { __index = MoveToCommand })
end

function MoveToCommand:execute(engine)
    local pos_comp = engine:GetComponent(self.entity_id, command_type_identifier, "Position")
    if not pos_comp then return end

    if self.params.target_pos.x ~= nil then pos_comp.x = self.params.target_pos.x end
    if self.params.target_pos.y ~= nil then pos_comp.y = self.params.target_pos.y end

    table.insert(engine.calls[command_type_identifier], {
        action = "update_position",
        entity_id = self.entity_id,
        from = { x = pos_comp.x, y = pos_comp.y },  -- before was lost, but we have intended initial
        to = { x = pos_comp.x, y = pos_comp.y }
    })

    BaseCommand.execute(self, engine)
end

function MoveToCommand:undo(engine)
    if self.from then
        local pos_comp = engine:GetComponent(self.entity_id, "Position")
        pos_comp.x = self.from.x
        pos_comp.y = self.from.y
    end
end

return MoveToCommand
