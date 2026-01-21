-- game_state.lua
local table_helper = require("helpers.table_helper")
local log_handler = require("log_handler")

local function find_actor_by_id(id)
    return table_helper.selectRecordById(current_scene.actors or {}, id)
end

local function update_actor_by_id(id, prop, value)
    table_helper.updateRecordById(current_scene.actors or {}, id, prop, value)
end

local function action_select_actor_by_id(id, value)
    local selected_actor = find_actor_by_id(id)
    log_handler.log_table("actor: update_actor_by_id", selected_actor)

    if selected_actor then
        update_actor_by_id(id, "selected", value)
        return true
    end

    return false
end

local function action_move_actor_by_id(id, direction, speed)
    speed = speed or 1
    local delta = speed / 100  -- convert to normalized units

    local actor = find_actor_by_id(id)

    log_handler.log_table("actor: move_actor_by_id", actor)

    if not actor then
        return false
    end

    -- Map direction to coordinate change
    local dir = string.lower(direction)
    local dx, dy = 0, 0
    if dir == "up" then dy = delta elseif dir == "down" then dy = -delta elseif dir == "left" then dx = -delta elseif dir == "right" then dx = delta
    else
        -- Optional: warn or ignore invalid direction
        print("Warning: Invalid direction '" .. tostring(direction) .. "' for move_actor_by_id")
        return false
    end

    -- Clamp to [-1, 1] range and update
    if dx ~= 0 then
        local new_x = math.clamp(actor.x + dx, -1, 1)
        update_actor_by_id(id, "x", new_x)
    end

    if dy ~= 0 then
        local new_y = math.clamp(actor.y + dy, -1, 1)
        update_actor_by_id(id, "y", new_y)
    end

    return true
end

function getByEntityId(sub, guid)
    local results = {}

    if sub then
        for _, entry in ipairs(sub) do
            if entry[1] == guid then  -- Direct comparison on the "first column"
                table.insert(results, entry[2])
            end
        end
    end
    return results
end

current_scene = current_scene or {}
-- CommandState = CommandState or {} -- This tracks User interaction from C# and Actors in GameState

function get_current_scene()
    return current_scene
end

-- Returns the currently selected actor (or nil)
local function find_selected_actor(gameState)
    local actors = gameState and gameState.actors or current_scene.actors or {}
    for _, actor in ipairs(actors) do
        if actor.selected then
            return actor
        end
    end
    return nil
end

-- Make sure the mock entity exists for this GUID
local function ensure_entity_exists(guid, actor_hint)
    local engine = _G.MockEngine
    local existing = engine:Get("entities", guid)

    if not existing then
        log_handler.log_data("Creating mock entity for actor: " .. tostring(guid))

        engine:CreateEntity(
            "entities",
            "PositionCommands",     -- or actor.type or something more specific
            {
                id          = guid,
                type        = "actor",
                name        = actor_hint and actor_hint.name or "Actor",
                -- you can copy initial position, rotation, etc. here if useful
            }
        )
    end

    return guid
end

-- Factory: turn raw input into a proper command object
local function create_command_from_input(input_cmd, entity_id, actor)
    if not input_cmd or not input_cmd.type then
        return nil
    end

    local cmd_type = input_cmd.type   -- e.g. "move_up", "move_left", "attack", etc.

    if cmd_type == "move_up" then
        return MoveUpCommand:new(entity_id, {
            speed = input_cmd.speed or 3,
            -- maybe actor-specific modifiers
        })
    elseif cmd_type == "move_left" then
        return MoveLeftCommand:new(entity_id, { speed = 3 })
    -- elseif cmd_type == "..." then ...
    else
        log_handler.log_data("Unknown input command type: " .. tostring(cmd_type))
        return nil
    end
end

return {
    find_actor_by_id = find_actor_by_id,
    find_selected_actor = find_selected_actor,
    select_actor_by_id = action_select_actor_by_id,
    move_actor_by_id = action_move_actor_by_id,
    update_actor_by_id = update_actor_by_id,
}
