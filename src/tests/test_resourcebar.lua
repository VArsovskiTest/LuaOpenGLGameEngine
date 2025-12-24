--resourcebar_test.lua
require("../src/tests/test_init")
local ResourceBar = require("resource_bar")

describe("ResourceBar => Regen, Damage tests", function()
    -- Create HP, Mana, Stamina
    local hp = {}
    local mana = {}
    local stamina = {}

    before_each(function()
        -- Setup
        hp = ResourceBar.create("hp")
        mana = ResourceBar.create("mana")
        stamina = ResourceBar.create("stamina")

        hp:set_maximum(100, false)
        mana:set_maximum(50, false)
        stamina:set_maximum(200, false)
    end)

    it("Regen works", function()
        hp:set_regen(2)              -- +2 HP/tick
        mana:set_regen_percentage(10)-- +10% mana/tick
        stamina:set_regen(5)        -- +10 stamina/tick

        hp:tick()
        mana:tick()
        stamina:tick()

        expect(hp:current()).to_equal(2)
        expect(mana:current()).to_equal(5)
        expect(stamina:current()).to_equal(5)
    end)

    it("Combat works", function()
        hp:set_maximum(100, true)
        mana:set_maximum(50, false)
        stamina:set_maximum(100, true)

        hp:subtract(30)             -- Take 30 damage
        mana:gain_percentage(40)    -- Mana potion
        stamina:subtract(20)        -- Sprint!

        hp:tick()
        mana:tick()
        stamina:tick()

        expect(hp:current()).to_equal(70)
        expect(mana:current()).to_equal(20)
        expect(stamina:current()).to_equal(80)
    end)

    it("Combat & Regen combined", function()
        hp:set_maximum(100, true)
        mana:set_maximum(100, true)
        stamina:set_maximum(100, true)

        hp:set_regen(2)
        mana:set_regen_percentage(5)
        stamina:set_regen(5)

        hp:subtract(30)                 -- Take 30 damage
        mana:subtract_percentage(60)    -- Cast spell
        stamina:subtract(20)            -- Sprint!

        hp:tick()
        mana:tick()
        stamina:tick()

        expect(hp:current()).to_equal(72)
        expect(mana:current()).to_equal(45)
        expect(stamina:current()).to_equal(85)    
    end)

    it("Reaches Maximum and stops", function()
        hp:set_regen(2)
        mana:set_regen_percentage(5)
        stamina:set_regen(10)

        hp:set_maximum(100, true)
        mana:set_maximum(50, true)
        stamina:set_maximum(100, true)

        hp:tick()
        mana:tick()
        stamina:tick()

        expect(hp:current()).to_equal(100)
        expect(mana:current()).to_equal(50)
        expect(stamina:current()).to_equal(100)
    end)

    summary()
end)
