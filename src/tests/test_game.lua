require("../src/tests/test_init")

local game = require("game")
local scene_sampler = require("helpers.scene_sampler")

describe("Rendering sample scene: ", function()
    it("Renders clear color", function()
        scene = scene_sampler.render_sample_scene()
        game.render_scene_with_params(scene.clears, scene.actors)
    end)
end)

return { render_sample_scene = render_sample_scene }
