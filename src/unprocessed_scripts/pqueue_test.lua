--pqueue_test.lua
require("../src/tests/test_init")

local pqueue = require("pqueue")

local q = pqueue.new()

q:addKV(1,1)
q:addKV(2,2)
q:addKV(3,2)
q:addKV(4,3)
q:addKV(5,1)
q:addKV(6,3)

print(q:min())
print(q:max())
print(q:empty())

for element in q:iterator() do
    print(element)
end

print(q:empty())
