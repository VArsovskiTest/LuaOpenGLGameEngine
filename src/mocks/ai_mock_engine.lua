-- engine/ai_mock_engine.lua
local MonsterStates = require("enums.monster_states")

local sampleMonster = {
    health = 100,
    max_health = 100,
    state = MonsterStates.IDLE,
    target = nil,
    sight_range = 15,
    attackType = "Melee",
    attack_range = 2,
    damage = 7,
    moveSpeed = 8,
    spellpower = 15,
}

local playerStart = { x = 0, y = 0 }

local initialPosition = { x = 10, y = 10 }

local monster_data = { Monster = sampleMonster, Position = initialPosition, PatrolPoints = {
        { x = 5, y = 5 }, { x = 0, y = 15 }, { x = 15, y = 0 }
    }, current_patrol_index = 1 }

local MockEngine = {
    calls = {
        MoveTo = {},
        DealDamage = {},
    },
    player = { Position = playerStart },
    entities = { [1001]= monster_data },
    player_weapon = "SWORD",
}

function MockEngine:CreateEntity(overrides)
    -- Default monster data
    local entity = {
        Position = initialPosition,
        Monster = sampleMonster,
        patrol_points = {},
    }

    -- Apply overrides (from test setup)
    if overrides then
        for k, v in pairs(overrides) do
            if k == "x" or k == "y" then
                entity[k] = v
                entity.Position[k] = v  -- keep Position in sync
            elseif k == "health" or k == "max_health" or k == "state" or 
                   k == "sight_range" or k == "attack_range" or 
                   k == "damage" or k == "moveSpeed" or k == "attackType" or
                   k == "spellpower" or k == "target" then
                entity.Monster[k] = v
            else
                entity[k] = v
            end
        end
    end

    return entity
end

-- Direct MoveTo with spy
function MockEngine:MoveTo(entity, target_pos)
    if not entity or not entity.Position then return end

    local old_x, old_y = entity.Position.x, entity.Position.y

    entity.Position.x = target_pos.x or target_pos.X or entity.Position.x
    entity.Position.y = target_pos.y or target_pos.Y or entity.Position.y

    -- entity.x = entity.Position.x
    -- entity.y = entity.Position.y

    -- Spy
    self.calls.MoveTo = self.calls.MoveTo or {}
    table.insert(self.calls.MoveTo, {
        entity = entity,
        from = { x = old_x, y = old_y },
        to = { x = entity.Position.x, y = entity.Position.y }
    })
end

function MockEngine:DealDamage(target, amount)
    if not target or not amount then return end
    self.calls.DealDamage = self.calls.DealDamage or {}
    table.insert(self.calls.DealDamage, { target = target, amount = amount })
end

function MockEngine:GetDistance(pos1, pos2)
    if not pos1 or not pos2 then
        return 99999
    end

    local x1 = (pos1.x or pos1.X or 0)
    local y1 = (pos1.y or pos1.Y or 0)
    local x2 = (pos2.x or pos2.X or 0)
    local y2 = (pos2.y or pos2.Y or 0)

    local dx = x1 - x2
    local dy = y1 - y2

    return math.sqrt(dx * dx + dy * dy)
end
function MockEngine:GetPlayerEquippedWeaponType() return self.player_weapon end
function MockEngine:SetPlayerPosition(x, y) self.player.Position.X = x self.player.Position.Y = y end
function MockEngine:SetPlayerWeapon(w) self.player_weapon = w end

function MockEngine:Reset()
    self.calls = { MoveTo = {}, DealDamage = {} }
end

return MockEngine
