-- src/game.lua

local function clear_render_table()
    for k in pairs(render) do
        render[k] = nil
    end
    -- or simply: render = {}
end

function update(dt)
    -- you can do game logic here later
end

render = render or {}

function render_scene()
    clear_render_table()

    table.insert(render, { type = "clear", r = 0.1, g = 0.15, b = 0.3 })

    local time = os.clock()
    local x = math.sin(time * 2) * 0.5

    table.insert(render, {
        type = "rect",
        x = x - 0.2,
        y = -0.3,
        w = 0.4,
        h = 0.6,
        r = 1, g = 0.3, b = 0.5
    })

    table.insert(render, {
        type = "rect",
        x = -0.8, y = -0.8,
        w = 0.3, h = 0.3,
        r = 0.8, g = 0.9, b = 0.2
    })

    return render
end

function initGame()
    print("Executing script: game")
    return render_scene()
end
