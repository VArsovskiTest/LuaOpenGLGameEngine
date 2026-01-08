local function handle_move_up() print ("Actor: moved up") end
local function handle_move_down() print ("Actor: moved down") end
local function handle_move_left() print ("Actor: moved left") end
local function handle_move_right() print ("Actor: moved right") end
local function handle_jump() print ("Actor: jumped") end
local function handle_attack() print ("Actor: attacked") end
local function handle_attack_alt() print ("Actor: attacked with an alt") end
local function handle_defend() print ("Actor: defended") end
local function handle_sprint() print ("Actor: sprinted") end
local function handle_boost() print ("Actor: boosted") end
local function handle_map() print ("Actor: opened map") end
local function handle_use_consumable() print ("Actor: used consumable") end
local function handle_engage() print ("Actor: engaged") end
local function handle_swap_main_attack() print ("Actor: swapped main attack") end
local function handle_swap_alt_attack() print ("Actor: swapped alternate attack") end
local function handle_select_1() print ("Actor: selected slot 1") end
local function handle_select_2() print ("Actor: selected slot 2") end
local function handle_select_3() print ("Actor: selected slot 3") end
local function handle_select_4() print ("Actor: selected slot 4") end
local function handle_select_5() print ("Actor: selected slot 5") end
local function handle_select_6() print ("Actor: selected slot 6") end
local function handle_select_7() print ("Actor: selected slot 7") end
local function handle_select_8() print ("Actor: selected slot 8") end
local function handle_select_9() print ("Actor: selected slot 9") end
local function handle_select_0() print ("Actor: selected slot 0") end

local ActorActions = {
    handle_move_up = handle_move_up,
    handle_move_down = handle_move_down,
    handle_move_left = handle_move_left,
    handle_move_right = handle_move_right,
    handle_jump = handle_jump,
    handle_attack = handle_attack,
    handle_defend = handle_defend,
    handle_sprint = handle_sprint,
    handle_boost = handle_boost,
    handle_map = handle_map,
    handle_use_consumable = handle_use_consumable,
    handle_engage = handle_engage,
    handle_swap_main_attack = handle_swap_main_attack,
    handle_swap_alt_attack = handle_swap_alt_attack,
    handle_select_1 = handle_select_1,
    handle_select_2 = handle_select_2,
    handle_select_3 = handle_select_3,
    handle_select_4 = handle_select_4,
    handle_select_5 = handle_select_5,
    handle_select_6 = handle_select_6,
    handle_select_7 = handle_select_7,
    handle_select_8 = handle_select_8,
    handle_select_9 = handle_select_9,
    handle_select_0 = handle_select_0,
}

return ActorActions
