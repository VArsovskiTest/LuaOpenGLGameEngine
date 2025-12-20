-- src/tests/ai/test_monster_behaviors.lua

local init = require("../src/tests/test_init")
init.init(_G.EngineModules.AI)

local h = _G.MockEngine

local MonsterBehaviors = require("ai.monster_behaviors")

describe("Monster Behaviors", function()
    before_each(function()
        h:Reset()
    end)

    it("starts in IDLE and transitions to PATROLLING when healthy", function()
        MonsterBehaviors:update(1001, 0.016, h)

        local monster = h.entities[1001].Monster
        expect(monster.state).to_equal("PATROLLING")
    end)

    it("detects player in sight range and starts CHASING (melee)", function()
        h.entities[1001].Monster.sight_range = 12
        h:SetPlayerPosition(5, 5)

        MonsterBehaviors:update(1001, 0.016, h)

        local monster = h.entities[1001].Monster
        expect(monster.state).to_equal("CHASING")
        expect(monster.target).to_equal("player")
    end)

    it("ranged/caster goes straight to ATTACKING when player is seen", function()
        h:SetPlayerWeapon("BOW")

        local m = h.entities[1001].Monster
        m.specialization = { attackType = "Ranged" }
        m.sight_range = 20

        h:SetPlayerPosition(15, 0)

        MonsterBehaviors:update(1001, 0.016, h)
        MonsterBehaviors:update(1001, 0.016, h)

        expect(m.state).to_equal("ATTACKING")
        expect(m.target).to_equal("player")
    end)

    it("deals spellpower damage when caster attacks", function()
        h:SetPlayerWeapon("STAFF")

        local m = h.entities[1001].Monster
        m.specialization = { attackType = "Caster" }
        m.spellpower     = 777
        m.sight_range    = 30

        h:SetPlayerPosition(1, 0)

        -- run ticks until we enter ATTACKING
        for i = 1, 30 do
            MonsterBehaviors:update(1001, 0.016, h)
            if m.state == "ATTACKING" then break end
        end

        -- one more tick to actually fire the spell
        MonsterBehaviors:update(1001, 0.016, h)

        local damageRecords = h.calls.DealDamage
        local last  = damageRecords[#damageRecords]
        expect(last).not_nil()
        expect(last["target"]).to_equal("player")
        expect(last["amount"]).to_equal(7)
    end)

    summary()
end)
