local MonsterStates = require("monster_states")

function monster.update(dt, self_id)
    -- C# provides the 'self_id' so we know who we are
    local player_pos = Engine.GetPlayerPosition()
    local my_pos = Engine.GetEntityPosition(self_id)
    local distance_to_player = Engine.GetDistance(my_pos, player_pos)

    -- State machine logic
    if monster.state == MonsterStates.PATROLLING then
        if distance_to_player < monster.sight_range then
            monster.state = MonsterStates.CHASING
            monster.target = "player"
        else
            -- Move towards the next patrol point
            local target_point = monster.patrol_points[monster.current_patrol_index]
            Engine.MoveTo(self_id, target_point) -- C# function
            if Engine.GetDistance(my_pos, target_point) < 1.0 then
                -- Reached the point, go to the next one
                monster.current_patrol_index = (monster.current_patrol_index % #monster.patrol_points) + 1
            end
        end

    elseif monster.state == MonsterStates.CHASING then
        if distance_to_player > monster.sight_range * 1.5 then -- Lost sight of player
            monster.state = MonsterStates.PATROLLING
            monster.target = nil
        elseif distance_to_player < monster.attack_range then
            monster.state = MonsterStates.ATTACKING
        else
            -- Move towards the player
            Engine.MoveTo(self_id, player_pos) -- C# function
        end

    elseif monster.state == MonsterStates.ATTACKING then
        -- This could be a coroutine to handle attack animation timing
        Engine.DealDamage("player", 10) -- C# function
        Engine.PlayAnimation(self_id, "slash") -- C# function
        monster.state = MonsterStates.CHASING -- Go back to chasing after attacking
    end
end
