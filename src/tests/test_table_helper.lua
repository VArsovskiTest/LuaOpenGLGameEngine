-- test_table_helper.lua
require("../src/tests/test_init")

-- Mock data
local current_scene = {
    actors = {
        { id = "a29f0ec1-4d88-4f3d-9b0a-0f8e12345678", name = "Player1", selected = false },
        { id = "b41f9ab2-5e99-4c2a-8d1b-1a2b3c4d5e6f", name = "Enemy1",  selected = true  },
        { id = "c52g0dc3-6f00-5e4e-9c2c-2b3c4d5e6f7g", name = "NPC1",    selected = false },
    }
}

local table_helper = require("helpers.table_helper")
local select_actor_by_id, update_actor_by_id = table_helper.selectRecordById, table_helper.updateRecordById

describe("update_actor_by_id with GUIDs", function()

    it("updates selected to true for existing actor when called with quoted GUID", function()
        local test_guid = "a29f0ec1-4d88-4f3d-9b0a-0f8e12345678"
        local actor = select_actor_by_id(current_scene.actors, test_guid)
        assert(actor.selected == false, "Initial state should be unselected")

        update_actor_by_id(current_scene.actors, test_guid, "selected", true)

        actor = select_actor_by_id(current_scene.actors, test_guid)
        assert(actor.selected == true, "selected should be updated to true")
    end)

    it("toggles selected back to false correctly", function()
        local test_guid = "a29f0ec1-4d88-4f3d-9b0a-0f8e12345678"

        update_actor_by_id(current_scene.actors, test_guid, "selected", false)

        local actor = select_actor_by_id(current_scene.actors, test_guid)
        assert(actor.selected == false, "selected should be toggled back to false")
    end)

    it("returns false when GUID does not exist", function()
        local fake_guid = "00000000-0000-0000-0000-000000000000"

        local result = update_actor_by_id(current_scene.actors, fake_guid, "selected", true)

        assert(result == false, "Should return false for non-existent GUID")
    end)

    it("correctly handles different actors and properties", function()
        local enemy_guid = "b41f9ab2-5e99-4c2a-8d1b-1a2b3c4d5e6f"

        update_actor_by_id(current_scene.actors, enemy_guid, "selected", false)

        local actor = select_actor_by_id(current_scene.actors, enemy_guid)
        assert(actor.selected == false, "Enemy actor should now be unselected")
    end)

    summary()
end)
