local color_pallette = require("enums.colors")
local ColoredResourceBar = require("models.colored_resource_bar")

local function render_sample_scene()
    local rects = {
        {
            type = "rect",
            x = 0.2,
            y = 0.1,
            w = 0.35,
            h = 0.1,
            color_id = color_pallette.TEAL,
        },
        {
            type = "rect",
            x = 0.7,
            y = 0.65,
            w = 0.15,
            h = 0.22,
            color_id = color_pallette.NAVY,
        },
        {
            type = "rect",
            x = -0.7,
            y = -0.25,
            w = 0.52,
            h = 0.17,
        },
    }

    local circles = {
        {
            type = "circle",
            x = -0.72,
            y = 0.55,
            rad = 0.12,
            color_id = color_pallette.SEA_GREEN,
        },
        {
            type = "circle",
            x = 0.92,
            y = 0.85,
            rad = 0.15,
            color_id = color_pallette.RED,
        },
    }

    local clears = {
        color_id = color_pallette.GRAY
    }

    local hp_bar = ColoredResourceBar:new("hp", color_pallette.RICH_MAGENTA)
    hp_bar:set_maximum(155, true)
    hp_bar:set_regen(0.35)
    hp_bar:set_maximum(250)
    local mana_bar = ColoredResourceBar:new("mana", color_pallette.BLUE)
    mana_bar:set_maximum(150, true)
    mana_bar:set_regen(1.75)
    mana_bar:set_maximum(200)
    local stamina_bar = ColoredResourceBar:new("s", color_pallette.GOLD)
    stamina_bar:set_maximum(120, true)
    stamina_bar:set_regen(5)

    hp_bar.x = -0.95;
    hp_bar.y = 0.05;
    mana_bar.x = -0.95;
    mana_bar.y = 0.1;
    stamina_bar.x = -0.95;
    stamina_bar.y = 0.15;

    local resource_bars = { hp_bar, mana_bar, stamina_bar }
    return clears, rects, resource_bars, circles
end

return { render_sample_scene = render_sample_scene }
