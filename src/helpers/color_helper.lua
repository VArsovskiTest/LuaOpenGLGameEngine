--color_helper.lua
local colorIDsSet = require("enums.colors")

local colors_rgba = {
    RED = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
    GREEN = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
    BLUE = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },
    BLACK = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
    WHITE = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    YELLOW = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 },
    CYAN = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
    MAGENTA = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
    ORANGE = { r = 1.0, g = 0.5, b = 0.0, a = 1.0 },
    PURPLE = { r = 0.5, g = 0.0, b = 0.5, a = 1.0 },
    PINK = { r = 1.0, g = 0.75, b = 0.8, a = 1.0 },
    BROWN = { r = 0.6, g = 0.3, b = 0.1, a = 1.0 },
    GRAY = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
    LIGHT_GRAY = { r = 0.75, g = 0.75, b = 0.75, a = 1.0 },
    DARK_GRAY = { r = 0.25, g = 0.25, b = 0.25, a = 1.0 },
    LIGHT_BLUE = { r = 0.68, g = 0.85, b = 0.9, a = 1.0 },
    DARK_BLUE = { r = 0.0, g = 0.0, b = 0.5, a = 1.0 },
    LIGHT_GREEN = { r = 0.5, g = 1.0, b = 0.5, a = 1.0 },
    DARK_GREEN = { r = 0.0, g = 0.39, b = 0.0, a = 1.0 },
    LIGHT_RED = { r = 1.0, g = 0.5, b = 0.5, a = 1.0 },
    DARK_RED = { r = 0.5, g = 0.0, b = 0.0, a = 1.0 },
    LIGHT_PURPLE = { r = 0.75, g = 0.5, b = 0.85, a = 1.0 },
    DARK_PURPLE = { r = 0.5, g = 0.0, b = 0.5, a = 1.0 },
    TEAL = { r = 0.0, g = 0.5, b = 0.5, a = 1.0 },
    NAVY = { r = 0.0, g = 0.0, b = 0.5, a = 1.0 },
    GOLD = { r = 1.0, g = 0.84, b = 0.0, a = 1.0 },
    SILVER = { r = 0.75, g = 0.75, b = 0.75, a = 1.0 },
    IVORY = { r = 1.0, g = 1.0, b = 0.94, a = 1.0 },
    CORAL = { r = 1.0, g = 0.5, b = 0.31, a = 1.0 },
    INDIGO = { r = 0.29, g = 0.0, b = 0.51, a = 1.0 },
    TAN = { r = 0.82, g = 0.70, b = 0.55, a = 1.0 },
    OLIVE = { r = 0.5, g = 0.5, b = 0.0, a = 1.0 },
    MAROON = { r = 0.5, g = 0.0, b = 0.0, a = 1.0 },
    LIME = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
    AQUA = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
    FUCHSIA = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
    BEIGE = { r = 0.96, g = 0.96, b = 0.86, a = 1.0 },
    SALMON = { r = 0.98, g = 0.5, b = 0.45, a = 1.0 },
    KHAKI = { r = 0.94, g = 0.9, b = 0.55, a = 1.0 },
    PLUM = { r = 0.87, g = 0.63, b = 0.87, a = 1.0 },
    CHOCOLATE = { r = 0.82, g = 0.41, b = 0.12, a = 1.0 },
    PEACH = { r = 1.0, g = 0.85, b = 0.7, a = 1.0 },
    LAVENDER = { r = 0.9, g = 0.9, b = 0.98, a = 1.0 },
    MINT = { r = 0.60, g = 1.0, b = 0.60, a = 1.0 },
    POWDER_BLUE = { r = 0.69, g = 0.88, b = 0.90, a = 1.0 },
    SEA_GREEN = { r = 0.18, g = 0.55, b = 0.34, a = 1.0 },
    VIOLET = { r = 0.93, g = 0.51, b = 0.93, a = 1.0 },
    RUST = { r = 0.78, g = 0.25, b = 0.25, a = 1.0 },
    CHARCOAL = { r = 0.26, g = 0.26, b = 0.26, a = 1.0 },
    SLATE_GRAY = { r = 0.44, g = 0.5, b = 0.56, a = 1.0 },
    BRONZE = { r = 0.80, g = 0.50, b = 0.20, a = 1.0 },
    WHEAT = { r = 0.96, g = 0.87, b = 0.70, a = 1.0 },
    RICH_BLACK = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
    RICH_CYAN = { r = 0.0, g = 0.5, b = 1.0, a = 1.0 },
    RICH_MAGENTA = { r = 1.0, g = 0.0, b = 0.5, a = 1.0 }
}

local ColorHelper = {}

local function validate(colorId)
    if not colorId then
        error("colorId cannot be nil!")
        return false
    end

    if colorIDsSet[colorId] then
        return true  -- colorId is valid
    else
        error("colorId must be valid!")
        return false
    end
end
local function createColorObject(colorId)
    if validate(colorId) then
        for _, color in ipairs(colors_rgba) do
            if color.id == colorId then
                return { r = color.r, g = color.g, b = color.b, a = color.a }
            end
        end
        return { r = 0, g = 0, b = 0, a = 1 }
    end
end

local function getColor(colorId)
    if validate(colorId) then
        for _, color in ipairs(colors) do
            if color.id == colorId then
                return color.r, color.g, color.b, color.a
            end
        end
        return 0, 0, 0, 1  -- Default to black if not found
    end
end

function ColorHelper:new()
    local self = ColorHelper

    local self = setmetatable({
        getColor = getColor,
        createColorObject = createColorObject
    }, ColorHelper)

    return self
end

return ColorHelper
