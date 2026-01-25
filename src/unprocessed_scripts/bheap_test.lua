--bheap_test.lua
require("../src/tests/test_init")

local bheap = require("bheap")

local q = bheap.new()

q:add(1,1)
q:add(2,2)
q:add(3,2)
q:add(4,3)
q:add(5,1)
q:add(6,3)

print(q:peek())    -- 1 (min)
print(q:size())    -- 6
print(q:empty())   -- false

for element in q:iterator() do
    print(element)  -- 1 5 2 3 4 6 (min priority FIRST!)
end

print(q:empty())   -- true
