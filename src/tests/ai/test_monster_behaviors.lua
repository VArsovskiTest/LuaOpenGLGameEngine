-- src/tests/ai/test_monster_behaviors.lua

require("../src/tests/test_init")
local h = require("helpers")                    -- your MockEngine + shortcuts
local MonsterBehaviors = require("ai.monster_behaviors")

describe("Monster Behaviors", function()
    before_each(function()
        h.reset()
    end)

    it("starts in IDLE and transitions to PATROLLING when healthy", function()
        MonsterBehaviors:update(1001, 0.016, h)

        local monster = h.entities[1001].Monster
        expect(monster.state).to_equal("PATROLLING")
    end)

    it("detects player in sight range and starts CHASING (melee)", function()
        h.entities[1001].Monster.sight_range = 12
        h.player:setPosition(5, 5)

        MonsterBehaviors:update(1001, 0.016, h)

        local monster = h.entities[1001].Monster
        expect(monster.state).to_equal("CHASING")
        expect(monster.target).to_equal("player")
    end)

    it("ranged/caster goes straight to ATTACKING when player is seen", function()
        h.set_player_weapon("BOW")

        local m = h.entities[1001].Monster
        m.specialization = { attackType = "Ranged" }
        m.sight_range    = 20

        h.player:setPosition(15, 0)

        MonsterBehaviors:update(1001, 0.016, h)
        MonsterBehaviors:update(1001, 0.016, h)  -- ranged skips straight to ATTACKING

        expect(m.state).to_equal("ATTACKING")
        expect(m.target).to_equal("player")
    end)

    it("deals spellpower damage when caster attacks", function()
        h.set_player_weapon("STAFF")

        local m = h.entities[1001].Monster
        m.specialization = { attackType = "Caster" }
        m.spellpower     = 777
        m.sight_range    = 30

        h.player:setPosition(1, 0)

        -- run ticks until we enter ATTACKING
        for i = 1, 30 do
            MonsterBehaviors:update(1001, 0.016, h)
            if m.state == "ATTACKING" then break end
        end

        -- one more tick to actually fire the spell
        MonsterBehaviors:update(1001, 0.016, h)

        local calls = h.calls.DealDamage
        local last  = calls[#calls]
        expect(last["target"]).to_equal("player")
        expect(last["amount"]).to_equal(7)
    end)
end)
