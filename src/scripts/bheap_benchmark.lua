local time = os.clock
local start = time()

local q = bheap.new()
for i = 1, 10000 do
    q:add(i, math.random(1, 100))
end

for _ = 1, 10000 do
    q:pop()
end

print("Binary Heap:", time() - start, "seconds")  -- ~0.02s!
