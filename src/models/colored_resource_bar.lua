-- Define the ColoredResourceBar Subclass
local ResourceBar = require("models.resource_bar")

local ColoredResourceBar = setmetatable({}, { __index = ResourceBar })
ColoredResourceBar.__index = ColoredResourceBar

function ColoredResourceBar:new(name, color_id)
    local self = ResourceBar.create(name)  -- Initialize the base class
    setmetatable(self, ColoredResourceBar)  -- Set the metatable for the new instance
    self.color_id = color_id or "DEFAULT_COLOR"  -- Add the color_id property
    return self
end

return ColoredResourceBar
