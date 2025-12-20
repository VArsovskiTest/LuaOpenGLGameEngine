-- ai/monster_behaviors.lua
local attackTypes     = require("enums.attack_types")
local MonsterStates   = require("enums.monster_states")   -- you probably have this
local MonsterBehaviors = {}
-- Helper functions (unchanged, but fixed small bugs)
local function checkRetreat(monster, player)
    local hp_percentage = monster.health / monster.max_health
    local retreat_threshold_fallback = 0.25
    if monster.specialization.isScout and hp_percentage < 0.55 then
        return true
    elseif monster.specialization.isElite then
        return false
    elseif hp_percentage < (monster.retreat_threshold or retreat_threshold_fallback) and not player.isEquippedWithRangeWeapon then
        return true
    end
    return false
end
local function checkCallReinforcements(monster)
    local hp_percentage = monster.health / monster.max_health
    if monster.specialization.isScout and hp_percentage < 0.35 then
        return true
    elseif monster.specialization.isElite and hp_percentage < 0.65 then
        return true
    end
    return false
end
local function checkEngage(monster, player, distance)
    if monster.attackType == attackTypes.RANGED or monster.attackType == attackTypes.CASTER then
        return true
    elseif (monster.armaments and #monster.armaments > 0) or monster.isEnraged then
        return true
    else
        return distance <= 0.75 * monster.sight_range
    end
end
-- MAIN UPDATE FUNCTION – this is the one that works with your tests
function MonsterBehaviors:update(self_id, dt, Engine)
    local entity   = Engine.entities[self_id]
    if not entity then return end
    local monster  = entity.Monster
    if not monster then return end

    local player_pos   = Engine.player.Position
    local my_pos       = entity.Position
    local distance     = Engine:GetDistance(my_pos, player_pos)
    local player_weapon = Engine:GetPlayerEquippedWeaponType()

    local player = { isEquippedWithRangeWeapon = (player_weapon == "BOW" or player_weapon == "STAFF") }

    -- State machine
    if monster.state == MonsterStates.IDLE and monster.health > 0 then
        monster.state = MonsterStates.PATROLLING
    end
    if monster.state == MonsterStates.PATROLLING then
        if checkEngage(monster, player, distance) then
            monster.target = "player"
            if monster.attackType == attackTypes.RANGED or monster.attackType == attackTypes.CASTER then
                monster.state = MonsterStates.ATTACKING
            else
                monster.state = MonsterStates.CHASING
            end
        else
            -- Simple patrol behaviour – just to keep it alive
            local point = entity.PatrolPoints[entity.current_patrol_index]
            if point then
                Engine:MoveTo(entity, point)
                if Engine:GetDistance(my_pos, point) < 1.0 then
                    entity.current_patrol_index = (entity.current_patrol_index % #entity.PatrolPoints) + 1
                end
            end
        end
    elseif monster.state == MonsterStates.CHASING then
        if checkRetreat(monster, player) or distance > monster.sight_range * 1.5 then
            monster.state = MonsterStates.PATROLLING
            monster.target = nil
        elseif distance <= monster.attack_range then
            monster.state = MonsterStates.ATTACKING
        else
            Engine:MoveTo(entity, player_pos)
        end
    elseif monster.state == MonsterStates.ATTACKING then
        local damage = (monster.attackType == attackTypes.CASTER) and monster.spellpower or monster.damage
        Engine:DealDamage("player", damage)
        monster.state = MonsterStates.CHASING   -- or stay ATTACKING, whatever you prefer
    end
    -- DO NOT return monster or anything else → prevents colon-chain bugs
end
return MonsterBehaviors