--calc_test.lua
require("../src/tests/test_init")

local calc = require("calc")

local x = 1
local y = 2

if assert(calc.add(x, y) == 3) then
print("It works :)")
end
