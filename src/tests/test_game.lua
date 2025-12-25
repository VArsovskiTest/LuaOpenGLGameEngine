require("../src/tests/test_init")

local game = require("game")
local scene_sampler = require("helpers.scene_sampler")
local table_helper = require("helpers.table_helper")

describe("Rendering sample scene: ", function()
    local sample_scene = scene_sampler.render_sample_scene()
    it("Renders clear color", function()
        game.render_scene_with_params(sample_scene.clears, sample_scene.actors)
    end)
    it("works with the exact C# DoString call pattern (quoted GUID + true/false)", function()
        -- Save original
        local mock_scene = sample_scene
        local original_render_scene = game.render_scene

        -- Mock render_scene to set the internal current_scene (via render_scene_with_params)
        game.render_scene = function()
            -- This mimics what the real render_scene does
            current_scene = game.render_scene_with_params(mock_scene.clears, mock_scene.actors)
            return current_scene
        end

        -- CRITICAL: Call it to initialize the module-internal current_scene
        game.render_scene()

        -- Now the internal current_scene used by update_actor_by_id is populated!

        local actor_id = mock_scene.actors[1].id
        
        -- Reset selected for clean test
        game.update_actor_by_id(actor_id, "selected", false)

        -- Simulate C# call
        local simulated_call = string.format(
            'update_actor_by_id("%s", "selected", true)',
            actor_id
        )

        local chunk = assert(load(simulated_call))
        chunk()  -- this calls the module's update_actor_by_id

        -- Verify
        local actor = game.select_actor_by_id(actor_id)
        assert(actor ~= nil, "Actor should be found")
        assert(actor.selected == true, "Actor should be selected after update")

        -- Restore
        game.render_scene = original_render_scene
    end)

    summary()
end)

return { render_sample_scene = render_sample_scene }
