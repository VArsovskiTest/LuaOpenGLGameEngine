-- commands/move_to_command.lua
local BaseCommand = require("commands.base_command")
local command_type_identifier = "Position_Commands"

local MoveToCommand = {}

function MoveToCommand:new(entity_id, cmd)
    local from_x = cmd.from_x or 0
    local from_y = cmd.from_y or 0

    local target_x = cmd.to_x ~= nil and cmd.to_x or from_x
    local target_y = cmd.to_y ~= nil and cmd.to_y or from_y

    local params = {
        initial_pos = { x = from_x, y = from_y },
        target_pos  = { x = target_x, y = target_y }
    }

    local self = BaseCommand.new("MoveToCommand", entity_id, params)
    self.class = MoveToCommand
    self.__index = MoveToCommand
    return setmetatable(self, { __index = MoveToCommand })
end

function MoveToCommand:getOrigin() return self.params.initial_pos end
function MoveToCommand:getTarget() return self.params.target_pos end

function MoveToCommand:execute(engine)
    -- log_handler.log_table("MoveToCommand: engine", engine)
    local pos_comp = engine:GetComponent(self.entity_id, command_type_identifier, "Position")
    if not pos_comp then return end

    if self.params.target_pos.x ~= nil then pos_comp[2].x = self.params.target_pos.x end
    if self.params.target_pos.y ~= nil then pos_comp[2].y = self.params.target_pos.y end

    table.insert(engine.calls[command_type_identifier], {
        action = "update_position",
        entity_id = self.entity_id,
        from = { x = pos_comp[1].x, y = pos_comp[1].y },  -- before was lost, but we have intended initial
        to = { x = pos_comp[2].x, y = pos_comp[2].y }
    })

    log_handler.log_table("Adding Component to engine", self)

    -- TODO: looks like the whole enqueue command system doesn't work unless I do this ?
    engine:AddComponent(self.id, "Position_Commands", "Position", { self:getOrigin(), self:getTarget() }) -- _G.MockEngine

    log_handler.log_data("Moving actor: " .. tostring(self.id))
    -- TODO: Invoke this from here ?
    game.move_actor_by_id(self.id, self.params.target_pos)

    BaseCommand.execute(self, engine)
end

function MoveToCommand:undo(engine)
    local pos_comp = engine:GetComponent(self.entity_id, command_type_identifier, "Position")
    if not pos_comp then return end

    if self.params.initial_pos.x ~= nil then pos_comp[2].x = self.params.initial_pos.x end
    if self.params.initial_pos.y ~= nil then pos_comp[2].y = self.params.initial_pos.y end

    table.insert(engine.calls[command_type_identifier], {
        action = "update_position",
        entity_id = self.entity_id,
        from = { x = pos_comp[2].x, y = pos_comp[2].y },
        to = { x = pos_comp[1].x, y = pos_comp[1].y }
    })

    BaseCommand.undo(self, engine)
end

return MoveToCommand
