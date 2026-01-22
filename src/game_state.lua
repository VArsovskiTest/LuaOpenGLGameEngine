-- game_state.lua
local table_helper = require("helpers.table_helper")
local log_handler = require("log_handler")

local ENTITY_BUCKET     = "entities"
local LIFECYCLE_LOG     = "EntityLifecycle"   -- or "Lifecycle" or "Actors"

state = { current_scene = { actors = {} } }

local function add_actors(actors)
    if actors then
        state.current_scene.actors = actors
    else
        log_handler.warn("Attempted to scene without actors")
    end
end

local function find_actor_by_id(id)
    local uuid = (tostring(id):match("^[^:]+") or ""):match("^%s*(.-)%s*$")
    local actors_clears = state.current_scene.actors or {}
    for _, actor in ipairs(actors_clears.actors) do
        -- id = type(id) == "table" or type(id) == "function" and id() or tostring(id)
        if uuid == actor.id then return actor end
    end
    -- return table_helper.selectRecordById(state.current_scene.actors or {}, id)

    return nil
end

function ensure_actor_registered(guid, actor_hint)
    local engine = _G.MockEngine
    local existing_entity = engine:Get(ENTITY_BUCKET, guid)
    log_handler.log_table("existing_entity", existing_entity)

    if not existing_entity then
        engine:CreateEntity(
            ENTITY_BUCKET,       -- current state storage
            LIFECYCLE_LOG,       -- lifecycle event log (spawn happened)
            {
                id    = guid,
                type  = "actor",
                name  = actor_hint.name or "Actor",
                -- x     = actor_hint.x or 0,
                -- y     = actor_hint.y or 0,
                -- ... copy useful initial state
            }
        )
    end
    return guid
end

local function update_actor_by_id(id, prop, value)
    table_helper.updateRecordById(state and state.current_scene.actors or {}, id, prop, value)
end

local function action_select_actor_by_id(id, value)
    local selected_actor = find_actor_by_id(id)
    log_handler.log_table("actor: update_actor_by_id", selected_actor)

    if selected_actor then
        update_actor_by_id(id, "selected", value)
        -- self.CurrentActor = actor
        state.current_scene.CurrentActor = actor
        ensure_actor_registered(guid, actor)   -- one-time setup
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

-- Returns the currently selected actor (or nil)
local function find_selected_actor(gameState)
    local actors = gameState and gameState.actors or state.current_scene.actors or {}
    for _, actor in ipairs(actors) do
        if actor.selected then
            return actor
        end
    end
    return nil
end

-- Factory: turn raw input into a proper command object

game_state = {
    state = state,
    add_actors = add_actors,
    find_actor_by_id = find_actor_by_id,
    find_selected_actor = find_selected_actor,
    ensure_actor_registered = ensure_actor_registered,
    select_actor_by_id = action_select_actor_by_id,
    move_actor_by_id = action_move_actor_by_id,
    update_actor_by_id = update_actor_by_id,
}

return game_state