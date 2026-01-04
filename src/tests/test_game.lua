require("../src/tests/test_init")

local game = require("game")
local scene_sampler = require("helpers.scene_sampler")
local table_helper = require("helpers.table_helper")

local find_actor_by_id = game.find_actor_by_id;
local select_actor_by_id = game.select_actor_by_id;
local move_actor_by_id = game.move_actor_by_id;

local sample_scene = scene_sampler.render_sample_scene()

describe("Rendering: ", function()
    it("Renders clear color", function()
        game.render_scene_with_params(sample_scene.clears, sample_scene.actors)
    end)
end)

describe("State actor functions, selection: ", function()
    it("works with the exact C# DoString call pattern (quoted GUID + true/false)", function()
        local mock_scene = sample_scene
        local original_render_scene = game.render_scene

        game.render_scene = function()
            current_scene = game.render_scene_with_params(mock_scene.clears, mock_scene.actors)
            return current_scene
        end

        game.render_scene()
        local actor_id = mock_scene.actors[1].id
        select_actor_by_id(actor_id, false)

        -- Simulate exact C# DoString call
        local simulated_call = string.format(
            'game.select_actor_by_id("%s", true)',
            actor_id
        )

        local chunk = assert(load(simulated_call))
        chunk()  -- executes game.select_actor_by_id(...)

        -- Verify
        local actor = game.find_actor_by_id(actor_id)
        assert(actor ~= nil, "Actor should be found")
        assert(actor.selected == true, "Actor should be selected after update")

        -- Restore
        game.render_scene = original_render_scene
    end)
end)

describe("State action functions, move: ", function()
    local player_id = sample_scene.actors[1].id 
    local actor = {}

    -- Reset actor position before each test
    before_each(function()
        actor = find_actor_by_id(player_id)
        actor.x = 0
        actor.y = 0
    end)

    it("moves actor right correctly", function()
        assert(move_actor_by_id(player_id, "right", 10) == true)
        local actor = find_actor_by_id(player_id)
        assert(actor.x == 0.1)  -- 10 / 100 = 0.1
        assert(actor.y == 0)
    end)

    it("moves actor left correctly", function()
        assert(move_actor_by_id(player_id, "left", 20) == true)
        local actor = find_actor_by_id(player_id)
        assert(actor.x == -0.2)
    end)

    it("moves actor up and down correctly", function()
        assert(move_actor_by_id(player_id, "up", 30) == true)
        local actor = find_actor_by_id(player_id)
        assert(actor.y == 0.3)

        assert(move_actor_by_id(player_id, "down", 50) == true)
        assert(actor.y == -0.2)  -- 0.3 - 0.5 = -0.2
    end)

    it("clamps position at boundaries", function()
        -- Move way beyond limit
        for i = 1, 50 do
            move_actor_by_id(player_id, "right", 10)
        end
        local actor = find_actor_by_id(player_id)
        assert(actor.x == 1, "Should be clamped to max 1")

        for i = 1, 50 do
            move_actor_by_id(player_id, "left", 10)
        end
        assert(actor.x == -1, "Should be clamped to min -1")
    end)

    it("returns false for invalid direction", function()
        assert(move_actor_by_id(player_id, "diagonal", 10) == false)
        assert(move_actor_by_id(player_id, "UP", 10) == true)  -- case-insensitive
    end)

    it("returns false for non-existent actor", function()
        assert(move_actor_by_id("ghost-999", "up", 10) == false)
    end)
end)

summary()

return { render_sample_scene = render_sample_scene }
