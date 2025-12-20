-- damagecomponent.lua
local StringUtil = require('string_util')
local stringify = StringUtil.stringify

-- Interfaces and Enums
local DamageTypes = {
    melee = 0,
    ranged = 1,
    elemental_melee = 2,
    elemental_ranged = 3
}

local DamageDifferential = {
    physical_differential = 0,
    physical_percentage = 0,
    elemental_differential = 0,
    elemental_percentage = 0
}
setmetatable(DamageDifferential, {__index = DamageDifferential})

local ItemDamage = {
    amount = 0,
    physical_amount = 0,
    elemental_amount = 0,
    base_physical_amount = 0, -- New field for base damage
    base_elemental_amount = 0, -- New field for base damage
    reach = 1,
    reach_angle = 0,
    differentials = {}
}
setmetatable(ItemDamage, {__index = ItemDamage})

local DamageComponent = {}
DamageComponent.__index = DamageComponent

-- Helper function to check if a value is in DamageTypes
local function is_valid_damage_type(value)
    for _, v in pairs(DamageTypes) do
        if v == value then
            return true
        end
    end
    return false
end

function DamageComponent:new(damage_data, damage_type, differentials)
    -- Validate damage_data is a table or nil
    if damage_data and type(damage_data) ~= "table" then
        error("damage_data must be a table or nil")
    end

    -- Validate damage_type
    if damage_type and not is_valid_damage_type(damage_type) then
        error("Damage type not met")
    end

    -- Set default values based on ItemDamage, overriding with damage_data if provided
    local val = {
        amount = (damage_data and damage_data.amount) or 0,
        physical_amount = (damage_data and damage_data.physical_amount) or 0,
        elemental_amount = (damage_data and damage_data.elemental_amount) or 0,
        base_physical_amount = (damage_data and damage_data.physical_amount) or 0, -- Store base damage
        base_elemental_amount = (damage_data and damage_data.elemental_amount) or 0, -- Store base damage
        reach = (damage_data and damage_data.reach) or 1,
        reach_angle = (damage_data and damage_data.reach_angle) or 30,
        capacity = (damage_data and damage_data.capacity) or 1,
        damage_type = damage_type or DamageTypes.melee,
        differentials = differentials or (damage_data and damage_data.differentials) or {}
    }

    -- Validate differentials
    for i, diff in ipairs(val.differentials) do
        if type(diff) ~= "table" or getmetatable(diff) ~= DamageDifferential then
            error("Invalid differential at index " .. i .. ": must be a table with DamageDifferential metatable")
        end
    end

    local self = { _val = val }
    setmetatable(self, DamageComponent)

    return self
end

function DamageComponent:set_damage(base_differential)
    local v = self._val
    v.amount = base_differential.amount or 0
    v.physical_amount = base_differential.physical_amount or 0
    v.elemental_amount = base_differential.elemental_amount or 0
    v.base_physical_amount = base_differential.physical_amount or 0 -- Update base damage
    v.base_elemental_amount = base_differential.elemental_amount or 0 -- Update base damage
    v.reach = base_differential.reach or 0
    v.reach_angle = base_differential.reach_angle or 0
    -- Preserve existing differentials
end

function DamageComponent:enchant(differential)
    local v = self._val
    if differential and getmetatable(differential) ~= DamageDifferential then
        error("Type for damage differentials not met")
    end
    table.insert(v.differentials, differential)
end

function DamageComponent:disenchant(differential)
    local v = self._val
    
    if differential then
        if getmetatable(differential) ~= DamageDifferential then
            error("Type for damage differentials not met")
        end
    end
    if v.differentials then
        for i, diff in ipairs(v.differentials) do
            if diff == differential then
                table.remove(v.differentials, i)
                break
            end
        end
    else
        print("differentials table is empty or nil")
    end
end

function DamageComponent:apply_damage()
    local v = self._val
    -- Reset to base damage values
    v.physical_amount = v.base_physical_amount
    v.elemental_amount = v.base_elemental_amount

    -- Apply differentials
    local physical_amount = 0
    local elemental_amount = 0

    for _, differential in ipairs(v.differentials) do
        local physical_differential = differential.physical_differential or 0
        local elemental_differential = differential.elemental_differential or 0
        local physical_boost = physical_differential * (differential.physical_percentage or 0) / 100
        local elemental_boost = elemental_differential * (differential.elemental_percentage or 0) / 100

        physical_amount = physical_amount + physical_differential + physical_boost
        elemental_amount = elemental_amount + elemental_differential + elemental_boost
    end

    v.physical_amount = v.physical_amount + physical_amount
    v.elemental_amount = v.elemental_amount + elemental_amount
    v.amount = v.physical_amount + v.elemental_amount
end

-- Export DamageComponent, DamageTypes, and DamageDifferential
return {
    DamageComponent = DamageComponent,
    DamageTypes = DamageTypes,
    DamageDifferential = DamageDifferential
}
