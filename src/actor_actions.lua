--actor_actions.lua

local CommandQueue = require("commands.command_queue")
local MoveToCommand = require("commands.move_to_command")
local MoveUpCommand = require("commands.move_up_command")
local MoveDownCommand = require("commands.move_down_command")
local MoveLeftCommand = require("commands.move_left_command")
local MoveRightCommand = require("commands.move_right_command")
local DrinkPotionCommand = require("commands.drink_potion_command")

local function handle_move_to(id, state) return MoveToCommand:new(id, state) end -- -- Required Params = from_x, from_y, speed
local function handle_move_up(id, state) return MoveUpCommand:new(id, state) end -- -- Required Params = from_x, from_y, speed
local function handle_move_down(id, state) return MoveDownCommand:new(id, state) end -- -- Required Params = from_x, from_y, speed
local function handle_move_left(id, state) return MoveLeftCommand:new(id, state) end -- -- Required Params = from_x, from_y, speed
local function handle_move_right(id, state) return MoveRightCommand:new(id, state) end -- -- Required Params = from_x, from_y, speed
local function handle_use_consumable(id, state) return DrinkPotionCommand:new(id, state) end
local function handle_jump(id, state) end
local function handle_attack(id, state) end
local function handle_attack_alt(id, state) end
local function handle_defend(id, state) end
local function handle_sprint(id, state) end
local function handle_boost(id, state) end
local function handle_map(id, state) end
local function handle_engage(id, state) end
local function handle_swap_main_attack(id, state) end
local function handle_swap_alt_attack(id, state) end
local function handle_select_1(id, state) end
local function handle_select_2(id, state) end
local function handle_select_3(id, state) end
local function handle_select_4(id, state) end
local function handle_select_5(id, state) end
local function handle_select_6(id, state) end
local function handle_select_7(id, state) end
local function handle_select_8(id, state) end
local function handle_select_9(id, state) end
local function handle_select_0(id, state) end

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
