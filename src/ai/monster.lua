local MonsterBehavior = require('monster_behavior')
local AttackTypes = require("enums.attack_types")

-- Defaults
local armaments = {}
local specialization = {isElite: true}

local specializations = { isCaster : false, isElite : false, isScout : false, isEnraged: false, isTactitian: false }

local defaults = {
    name = "Generic Monster (Melee)",
    max_hp = 100,
    hp = 100,
    hp_regen = 0.5,
    max_resource = 0,
    resource = 0,
    resource_regen = 0,
    damage = 5,
    spellpower = 0,
    sight_range = 10,
    retreat_threshold = 0.3,
    armaments = armaments,
    specialization = specialization,
    attackType = AttackTypes.MELEE
}

local Monster = {}
Monster.__index = Monster

function Monster:new(name, stats, armaments, specialization)
    local instance = setmetatable({}, Monster)
    instance.name = name

    instance.max_hp = stats.max_hp or defaults.max_hp
    instance.hp = stats.hp or defaults.hp
    instance.hp_regen = stats.hp_regen or defaults.hp_regen

    instance.max_resource = stats.max_resource or defaults.max_resource
    instance.resource = stats.resource or defaults.resource
    instance.resource_regen = stats.resource_regen or defaults.resource_regen

    instance.damage = stats.damage or defaults.damage
    instance.spellpower = stats.spellpower or defaults.spellpower
    instance.sight_range = stats.sight_range or defaults.sight_range
    instance.retreat_threshold = stats.retreat_threshold or defaults.retreat_threshold

    instance.armaments = stats.armaments or defaults.armaments
    instance.specialization = specialization or defaults.specialization

    -- Adjust HP and damage based on elite status
    if instance.specialization.isScout then
        instance.max_hp = instance.max_hp * 1.3
        instance.sight_range = instance.sight_range + 5
    end
    if instance.specialization.isCaster then
        instance.resource = instance.energy * 2.5
        instance.resource_regen = 1.2
        instance.spellpower = instance.spellpower + 2
    end
    if instance.specialization.isElite then
        instance.max_hp = instance.max_hp * 7
        instance.damage = instance.damage * 2.5
        instance.spellpower = instance.spellpower + 5
    end
    if instance.specialization.isEnraged then
        instance.damage = instance.damage * 1.6
    end
    if instance.specialization.isTactitian then
        for _, armament in ipairs(instance.armaments) do
            armament.quantity = math.max(armament.quantity * 2, 5)
        end
    end
    
    -- Additional behavior based on flags
    if instance.armaments and instance.ammo == -1 then
        instance.attackType = AttackTypes.RANGED
    else if instance.isCaster then
        instance.attackType = AttackTypes.CASTER
    else
        instance.attackType = AttackTypes.MELEE
    end

    return instance
end

-- Helper methods for health and resource percentages
function Monster:hp_percentage()
    return self.hp / self.max_hp -- No need to check division by 0 here
end

function Monster:healthy() {
    return self.hp_percentage() >= 0.8
}

function Monster:resource_percentage()
    return self.max_resource == 0 and 0 or (self.resource / self.max_resource)
end

return Monster
