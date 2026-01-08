-- commands/move_to_command.lua
local BaseCommand = require("commands.base_command")
local potion_types = require("enums.potion_types")
local potion_sizes = require("enums.potion_sizes")
local command_type_identifier = "Action_Key_Commands"

local DrinkPotionCommand = {}

DrinkPotionModel = { type = nil, size = nil }

DrinkPotionCommand.__index = DrinkPotionCommand

local potion_size_values = {
    potion_sizes.MINOR = 15,
    potion_sizes.SMALL = 30,
    potion_sizes.REGULAR = 45,
    potion_sizes.LARGE = 66,
    potion_sizes.FULL = 100
}

function DrinkPotionCommand.new(entity_id, potion_data)
    if potion_data and getmetatable(potion_data) ~= DrinkPotionModel then
        error("potion_data must be a DrinkPotionModel!")
    end

    local params = {
        type = potion_data.potion_type,
        size = potion_size_values[potion_data.potion_size or potion_sizes.MINOR]
    }
    
    local self = BaseCommand.new("DrinkPotionCommand", entity_id, params)
    self.class = DrinkPotionCommand

    function self:getType() return self.params.type end
    function self:getSize() return self.params.size end

    setmetatable(self, {__index = DrinkPotionCommand })

    return self
end

function DrinkPotionCommand:execute()
    -- TODO: queue to command_queue
end

function DrinkPotionCommand:undo()
end

return DrinkPotionCommand
