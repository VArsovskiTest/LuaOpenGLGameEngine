-- damagecomponent_test.lua
require("../src/tests/test_init")

local DamageComponentModule = require('damagecomponent')
local StringUtil = require('string_util')
local stringify = StringUtil.stringify
print("StringUtil:", StringUtil, StringUtil.stringify)

local DamageComponent = DamageComponentModule.DamageComponent
local DamageTypes = DamageComponentModule.DamageTypes
local DamageDifferential = DamageComponentModule.DamageDifferential

-- Define the DamageDifferential for testing
local slash_differential = setmetatable({
    physical_differential = 10,
    physical_percentage = 50,
    elemental_differential = 5,
    elemental_percentage = 0
}, DamageDifferential)

local elemental_differential = setmetatable({
    physical_differential = 5,
    physical_percentage = 0,
    elemental_differential = 10,
    elemental_percentage = 50
}, DamageDifferential)

-- Function to create and test a DamageComponent with apply_damage
local function test_damage_item(name, base_damage, damage_type, reach, differential, expected_physical_amount, expected_elemental_amount, expected_total)
    print("Testing apply_damage for " .. name .. "...")
    
    local physical_base_damage = ((damage_type == DamageTypes.melee or damage_type == DamageTypes.ranged) and base_damage) or 0
    local elemental_base_damage = ((damage_type == DamageTypes.elemental_melee or damage_type == DamageTypes.elemental_ranged) and base_damage) or 0

    local damage_data = {
        amount = 0,
        physical_amount = physical_base_damage,
        elemental_amount = elemental_base_damage,
        reach = reach,
        reach_angle = 30,
        differentials = {}
    }
    
    local damage_item = DamageComponent:new(damage_data, damage_type, {})

    damage_item:set_damage(damage_data)
    damage_item:enchant(differential)
    damage_item:apply_damage()

    -- Assert results
    if damage_item._val.physical_amount ~= expected_physical_amount then
        print(name .. " - Physical amount does not match expected: got " .. damage_item._val.physical_amount .. ", expected " .. expected_physical_amount)
        print("damage_item: " .. stringify(damage_item._val))
    else
        print(name .. " - Physical amount matches: " .. damage_item._val.physical_amount)
    end
    if damage_item._val.elemental_amount ~= expected_elemental_amount then
        print(name .. " - Elemental amount does not match expected: got " .. damage_item._val.elemental_amount .. ", expected " .. expected_elemental_amount)
        print("damage_item: " .. stringify(damage_item._val))
    else
        print(name .. " - Elemental amount matches: " .. damage_item._val.elemental_amount)
    end
    if damage_item._val.amount ~= expected_total then
        print(name .. " - Total amount does not match expected: got " .. damage_item._val.amount .. ", expected " .. expected_total)
        print("damage_item: " .. stringify(damage_item._val))
    else
        print(name .. " - Total amount matches: " .. damage_item._val.amount)
    end
end

-- Function to test disenchant method
local function test_disenchant(name, base_damage, damage_type, reach, differential, expected_base_physical, expected_base_elemental, expected_base_total)
    print("Testing disenchant for " .. name .. "...")
    
    local physical_base_damage = ((damage_type == DamageTypes.melee or damage_type == DamageTypes.ranged) and base_damage) or 0
    local elemental_base_damage = ((damage_type == DamageTypes.elemental_melee or damage_type == DamageTypes.elemental_ranged) and base_damage) or 0

    local damage_data = {
        amount = 0,
        physical_amount = physical_base_damage,
        elemental_amount = elemental_base_damage,
        reach = reach,
        reach_angle = 30,
        differentials = {}
    }
    
    local damage_item = DamageComponent:new(damage_data, damage_type, {})

    -- Set damage
    damage_item:set_damage(damage_data)
    damage_item:enchant(differential)
    damage_item:apply_damage()

    -- Disenchant, reset base damage, and re-apply damage
    damage_item:disenchant(differential)
    damage_item:set_damage(damage_data) -- Reset to base values
    damage_item:apply_damage()

    -- Assert results revert to base values
    if damage_item._val.physical_amount ~= expected_base_physical then
        print(name .. " - Physical amount does not match base: got " .. damage_item._val.physical_amount .. ", expected " .. expected_base_physical)
    else
        print(name .. " - Physical amount matches base: " .. damage_item._val.physical_amount)
    end
    if damage_item._val.elemental_amount ~= expected_base_elemental then
        print(name .. " - Elemental amount does not match base: got " .. damage_item._val.elemental_amount .. ", expected " .. expected_base_elemental)
    else
        print(name .. " - Elemental amount matches base: " .. damage_item._val.elemental_amount)
    end
    if damage_item._val.amount ~= expected_base_total then
        print(name .. " - Total amount does not match base: got " .. damage_item._val.amount .. ", expected " .. expected_base_total)
    else
        print(name .. " - Total amount matches base: " .. damage_item._val.amount)
    end
end

-- Test cases for apply_damage
test_damage_item("Knife", 10, DamageTypes.melee, 1.4, slash_differential, 25, 5, 30)
test_damage_item("Sword", 16, DamageTypes.melee, 2, slash_differential, 31, 5, 36)
test_damage_item("Staff", 9, DamageTypes.elemental_melee, 3.5, elemental_differential, 5, 24, 29)
test_damage_item("Polearm", 25, DamageTypes.melee, 5, slash_differential, 40, 5, 45)
test_damage_item("Bow", 9, DamageTypes.ranged, 15, slash_differential, 24, 5, 29)
test_damage_item("Ballista", 22, DamageTypes.elemental_ranged, 18, elemental_differential, 5, 37, 42)

-- Test cases for disenchant
test_disenchant("KnifeDisenchant", 10, DamageTypes.melee, 1.4, slash_differential, 10, 0, 10)
test_disenchant("StaffDisenchant", 9, DamageTypes.elemental_melee, 3.5, elemental_differential, 0, 9, 9)

-- Disenchant non-existent differential, expect no change from enchanted state
test_disenchant("KnifeNoChange", 10, DamageTypes.melee, 1.4, slash_differential, 25, 5, 30)
-- Disenchant from empty differentials, expect base damage
test_disenchant("KnifeEmpty", 10, DamageTypes.melee, 1.4, slash_differential, 10, 0, 10)
