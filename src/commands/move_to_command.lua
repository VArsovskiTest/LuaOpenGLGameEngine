-- commands/move_to_command.lua
local log_handler = require("log_handler")
local BaseCommand = require("commands.base_command")

local command_type_identifier = "PositionCommands"

local MoveToCommand = {}
MoveToCommand.super = BaseCommand

function MoveToCommand:new(entity_id, command_name, command_queue_name, component_name, params)
    -- command_name is usually "MoveToCommand" or subclass name like "MoveUpCommand"
    local self = BaseCommand:new(entity_id, command_name or "MoveToCommand",
                                 command_queue_name, component_name, params)

    -- Optional: add MoveTo-specific fields if needed
    -- self.move_duration = 0.5  -- example

    setmetatable(self, { __index = MoveToCommand })
    return self
end

function MoveToCommand:getOrigin()
    return self.params.initial_pos
end

function MoveToCommand:getTarget()
    return self.params.target_pos
end

function MoveToCommand:_call_execute(engine, entry)
    log_handler.log_data("MoveToCommand:_call_execute → calling Base")
    MoveToCommand.super._call_execute(self, engine, entry)
end

function MoveToCommand:execute(engine, entry)
    log_handler.log_data("MoveToCommand:execute started")

    local pos_comp = self.INITIAL_STATE
    if not pos_comp or type(pos_comp) ~= "table" then
        error("MoveToCommand: no valid starting position state")
    end

    -- Apply target if provided
    if not self.params.target_pos then
        self.params.target_pos = pos_comp.params.target_pos
    end

    -- Record the change (your engine.calls pattern)
    table.insert(engine.calls[command_type_identifier] or {}, {
        action     = "update_position",
        entity_id  = self.entity_id,
        from       = self.params.initial_pos.x or { x = 0, y = 0 },
        to         = self.params.target_pos.x or { x = 0, y = 0 },
    })

    -- Apply / commit
    engine:AddComponent(self.entity_id, command_type_identifier, "Position",
        { self:getOrigin(), self:getTarget() })

    log_handler.log_data("Moving actor: " .. tostring(self.entity_id))
    log_handler.log_table("to a new position: ", self.params.target_pos)
    game.move_actor_by_id(self.entity_id, self.params.target_pos)
end

function MoveToCommand:undo(engine)
    local pos_comp = engine:GetComponent(self.entity_id, command_type_identifier, "Position")
    if not pos_comp then return end

    if self.params.initial_pos.x ~= nil then pos_comp.target_pos.x = self.params.initial_pos.x end
    if self.params.initial_pos.y ~= nil then pos_comp.target_pos.y = self.params.initial_pos.y end

    table.insert(engine.calls[command_type_identifier], {
        action = "update_position",
        entity_id = self.entity_id,
        from = self.params.target_pos,
        to = self.params.initial_pos,
    })

    BaseCommand.undo(self, engine)
end

return MoveToCommand
