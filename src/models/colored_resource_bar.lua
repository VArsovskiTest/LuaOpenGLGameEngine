-- colored_resource_bar.lua
local ResourceBar = require("models.resource_bar")
local ColorHelper = require("helpers/color_helper"):new()
local color_pallette = require("enums.color_pallette")

local ColoredResourceBar = {}
ColoredResourceBar.__index = ColoredResourceBar

-- Inherit from ResourceBar
setmetatable(ColoredResourceBar, { __index = ResourceBar })

function ColoredResourceBar:new(name, color_id)
    local self = ResourceBar:new(name)          -- call parent constructor
    self.color_id = color_id or color_pallette.BLACK
    self.color = ColorHelper.createColorObject(self.color_id)
    
    -- Optional: mark as colored
    self.type = "colored_resource_bar"
    
    return setmetatable(self, ColoredResourceBar)
end

return ColoredResourceBar
