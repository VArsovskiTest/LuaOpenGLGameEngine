--rectangle.lua
local color_pallette = require("enums.color_pallette")
local guid_generator = require("helpers.guid_helper")
local color_helper = require("helpers/color_helper")
local ColorHelper = color_helper:new()

local Rectangle = {}
Rectangle.__index = Rectangle

function Rectangle:new(rectangle)
    local self = setmetatable({
            type = "rect",
            class = Rectangle,
            name = rectangle.name or "unnamed_rect",
            x = rectangle.x or 0,
            y = rectangle.y or 0,
            width = rectangle.w or rectangle.width or 0,
            height = rectangle.h or rectangle.height or 0,
            color_id = rectangle.color_id or color_pallette.TEAL,
            id = guid_generator.generate_guid(),
    }, Rectangle)

    self.color = ColorHelper.createColorObject(self.color_id)
    return self
end

return Rectangle