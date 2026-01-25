require("../src/tests/test_init")

local bheap = require("bheap")
local graph = {
    A = {B=4, C=2}, B = {D=5}, C = {B=1, D=8}, D = {}
}

local dist = {A=0}  -- distances
local prev = {}     -- previous nodes
local pq = bheap.new()
pq:add("A", 0)

while not pq:empty() do
    local u = pq:pop()
    local d = dist[u]
    
    for v, weight in pairs(graph[u]) do
        local alt = d + weight
        if not dist[v] or alt < dist[v] then
            dist[v] = alt
            prev[v] = u
            pq:add(v, alt)
        end
    end
end

print("A→D shortest path:", dist.D)  -- 6 (A→C→B→D)
