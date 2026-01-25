--clear.lua
local color_pallette = require("enums.color_pallette")
local guid_generator = require("helpers.guid_helper")
local color_helper = require("helpers/color_helper")
local ColorHelper = color_helper:new()

local Clear = {}
Clear.__index = Clear

function Clear:new(clear)
    local self = setmetatable({
        class = Clear,
        type = "clear",
        name = clear.name or "unnamed_clear",
        color_id = clear.color_id or color_pallette.BLACK,
        id = guid_generator.generate_guid(),
    }, Clear)

    self.color = ColorHelper.createColorObject(self.color_id)
    return self
end

return Clear
