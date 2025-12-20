--resourcebar_test.lua
require("../src/tests/test_init")

local ResourceBar = require("resourcebar")

-- Create HP, Mana, Stamina
local hp = ResourceBar:new()      -- Default 100 max
local mana = ResourceBar:new()    -- Default 100 max
local stamina = ResourceBar:new() -- Default 100 max

-- Setup
hp:set_maximum(100, true)
mana:set_maximum(50, true)
stamina:set_maximum(200, true)

hp:set_regen(2)              -- +2 HP/tick
mana:set_regen_percentage(5) -- +5% mana/tick
stamina:set_regen(10)        -- +10 stamina/tick

-- Combat!
hp:subtract(30)     -- Take 30 damage
mana:gain_percentage(20)  -- Mana potion
stamina:subtract(100)  -- Sprint!

print("BEFORE TICK:")
print("HP:", hp:current(), "/", hp:maximum())
print("Mana:", mana:current(), "/", mana:maximum())
print("Stamina:", stamina:current(), "/", stamina:maximum())

-- Simulate 3 seconds
for i = 1, 3 do
    hp:tick()
    mana:tick()
    stamina:tick()
    print("Tick", i, "- HP:", hp:current())
end

print("\nAFTER REGEN:")
print("HP:", hp:current(), hp:percentage(), "%")
print("Mana:", mana:current(), mana:percentage(), "%") 
print("Stamina:", stamina:current(), stamina:percentage(), "%")
