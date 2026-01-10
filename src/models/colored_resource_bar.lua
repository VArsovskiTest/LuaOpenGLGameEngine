-- colored_resource_bar.lua
local ResourceBar = require("models.resource_bar")
local ColorHelper = require("helpers.color_helper"):new()
local table_helper = require("helpers.table_helper")
local color_pallette = require("enums.color_pallette")

local ColoredResourceBar = {}
setmetatable(ColoredResourceBar, { __index = ResourceBar })   -- (1)
ColoredResourceBar.__index = ColoredResourceBar               -- (2)

local function generatePrivateColorData(color_id)
    local colorData = {
        color_id = color_id or color_pallette.BLACK
    }
    colorData.color = ColorHelper.createColorObject(colorData.color_id)
    return colorData
end

function ColoredResourceBar:getColorId()
    return self._data.color_id
end

function ColoredResourceBar:getColorValue()
    return self._data.color
end

function ColoredResourceBar:new(name, color_id, maximum, current)
    local resourceBar = ResourceBar:new(name, maximum, current)   -- call parent constructor
    local colorData = generatePrivateColorData();
    local self = table_helper.mergeTables({type = "resource_bar", class = ColoredResourceBar }, resourceBar, colorData)
    self.__index = ColoredResourceBar

    return setmetatable(self, ColoredResourceBar)
end

return ColoredResourceBar
