--circle.lua
local color_pallette = require("enums.color_pallette")
local guid_generator = require("helpers.guid_helper")
local color_helper = require("helpers/color_helper")
local ColorHelper = color_helper:new()

local Circle = {}
Circle.__index = Circle

function Circle:new(circle)
    local self = setmetatable({
        type = "circle",
        name = circle.name or "unnamed_circle",
        x = circle.x or 0,
        y = circle.y or 0,
        rad = circle.rad or 1,
        color_id = circle.color_id or color_pallette.SEA_GREEN,
        id = guid_generator.generate_guid(),
    }, Circle)

    self.color = ColorHelper.createColorObject(self.color_id)
    return self
end

return Circle
