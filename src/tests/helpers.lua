-- test/mock_engine.lua  (or inline in your test)

local MonsterStates = require("enums.monster_states")
local AttackTypes = require("enums.attack_types")
local MockEngine = {calls = {DealDamage = {}}}

-- Fake entity database – add whatever components your tests need
local player = {
    x = 50, y = 0,

    -- This is the method your tests expect
    setPosition = function(self, x, y)
        self.x = x
        self.y = y
        -- -- Also keep the real storage in sync
        -- local real = MockEngine.players[0].Position
        -- real.x = x
        -- real.y = y
    end,

    getPosition = function(self)
        return { x = self.x, y = self.y }
    end
}

local entities = {
    [1001] = {
        Position = { x = 10, y = 10 },
        Monster  = { attackType = AttackTypes.MELEE, damage = 7, sight_range = 15, attack_range = 2, moveSpeed = 8, state = MonsterStates.IDLE, hp = 50, max_hp = 65 },
        patrol_points = { {X=0,Y=0}, {X=30,Y=0}, {X=30,Y=30}, {X=0,Y=30} },
    },

    [1002] = {
        Position = { x = 80, y = 80 },
        Monster  = { attackType = AttackTypes.MELEE, damage = 17, sight_range = 25, attack_range = 10, moveSpeed = 12, state = MonsterStates.IDLE, hp = 320, max_hp = 65 },
        patrol_points = { {X=0,Y=0}, {X=30,Y=0}, {X=30,Y=30}, {X=0,Y=30} },
    },

    -- add more entities whenever a new test needs them
}

function MockEngine:GetComponent(entity_id, component_name)
    local entity = MockEngine.entities[entity_id]
    if not entity then return nil end
    return entity[component_name]
end

function MockEngine:GetPlayerPosition()
    local pos = MockEngine.player:getPosition()
    return { x = pos.x, y = pos.y }
end

function MockEngine:GetEntityPosition(entity_id)
    local pos = self:GetComponent(entity_id, "Position")
    if not pos then error("No Position component on entity " .. tostring(entity_id)) end
    return { x = pos.x, y = pos.y }
end

function MockEngine:MoveTo(entity_id, target_pos)
    local pos_comp = self:GetComponent(entity_id, "Position")
    if not pos_comp then return end   -- silent fail is fine in tests

    -- This is the REAL movement — required for AI to work
    pos_comp.x = target_pos.x or target_pos.X or pos_comp.x
    pos_comp.y = target_pos.y or target_pos.Y or pos_comp.y

    -- This is just a free spy — costs nothing, gives you free assertions later
    self.calls.MoveTo = self.calls.MoveTo or {}
    table.insert(self.calls.MoveTo, {
        entity_id = entity_id,
        from = { x = pos_comp.x, y = pos_comp.y },  -- before move
        to   = { x = target_pos.x or target_pos.X, y = target_pos.y or target_pos.Y }
    })
end

function MockEngine:DealDamage(target, amount)
    self.calls.DealDamage = self.calls.DealDamage or {}
    table.insert(self.calls.DealDamage, {target = target, amount = amount})
end

function MockEngine:GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 99999 end
    local dx = (pos1.X or pos1.x or 0) - (pos2.X or pos2.x or 0)
    local dy = (pos1.Y or pos1.y or 0) - (pos2.Y or pos2.y or 0)
    return math.sqrt(dx*dx + dy*dy)
end

function MockEngine:GetPlayerEquippedWeaponType()
    return self.player_weapon or "SWORD"
end

function MockEngine:GetEntityHealth(entity_id)
    local monster = self:GetComponent(entity_id, "Monster")
    return monster and monster.health or 100
end

function MockEngine:create(o)
    local m = {x=10,y=10,health=100,max_health=100,state=MonsterStates.IDLE,target=nil,
               sight_range=15,specialization={attackType="Melee"},spellpower=50}
    if o then for k,v in pairs(o) do m[k]=v end end
    return m
end

function MockEngine:reset()
    MockEngine.calls.DealDamage = {}
    MockEngine.entities = entities
    MockEngine.player = player
end

function MockEngine:set_player_weapon(w) MockEngine.GetPlayerEquippedWeaponType = function() return w end end

return MockEngine

-- -- make it globally available for tests
-- _G.h = setmetatable({}, {__index = MockEngine})

-- -- optional: auto-create entity 1001 so tests don't have to
-- _G.h.create_monster(1001)
