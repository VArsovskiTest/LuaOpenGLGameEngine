-- Binary Heap (Min-Heap) from previous
local bheap = {}
bheap.__index = bheap

function bheap.new()
    return setmetatable({heap = {}, priorities = {}}, bheap)
end

function bheap:add(key, priority)
    local h = self.heap
    h[#h + 1] = key
    self.priorities[key] = priority
    self:_bubbleUp(#h)
end

function bheap:pop()
    if #self.heap == 0 then return nil end
    local h = self.heap
    local minKey = h[1]
    
    h[1] = h[#h]
    self.priorities[h[1]] = self.priorities[h[#h]]
    h[#h] = nil
    
    self:_sinkDown(1)
    
    self.priorities[minKey] = nil
    return minKey
end

function bheap:peek()
    return self.heap[1]
end

function bheap:empty()
    return #self.heap == 0
end

function bheap:size()
    return #self.heap
end

function bheap:_bubbleUp(i)
    local h = self.heap
    local p = self.priorities
    while i > 1 do
        local parent = math.floor(i / 2)
        if p[h[i]] < p[h[parent]] then
            h[i], h[parent] = h[parent], h[i]
            i = parent
        else
            break
        end
    end
end

function bheap:_sinkDown(i)
    local h = self.heap
    local p = self.priorities
    local size = #h
    while true do
        local left = 2 * i
        local right = 2 * i + 1
        local smallest = i
        
        if left <= size and p[h[left]] < p[h[smallest]] then smallest = left end
        if right <= size and p[h[right]] < p[h[smallest]] then smallest = right end
        
        if smallest == i then break end
        
        h[i], h[smallest] = h[smallest], h[i]
        i = smallest
    end
end

-- Dijkstra's Algorithm
function dijkstra(graph, start)
    local dist = {}   -- Shortest distances
    local prev = {}   -- Previous nodes
    local pq = bheap.new()
    
    -- Init
    for node in pairs(graph) do
        dist[node] = math.huge
    end
    dist[start] = 0
    pq:add(start, 0)
    
    -- Main loop
    while not pq:empty() do
        local u = pq:pop()
        local d = dist[u]
        
        for v, weight in pairs(graph[u]) do
            local alt = d + weight
            if alt < (dist[v] or math.huge) then
                dist[v] = alt
                prev[v] = u
                pq:add(v, alt)  -- Heap allows duplicates (inefficient but works; optimize with decrease-key)
            end
        end
    end
    
    return dist, prev
end

-- Rebuild path from prev
function getPath(prev, start, goal)
    local path = {}
    local current = goal
    while current do
        table.insert(path, 1, current)
        current = prev[current]
        if current == start then
            table.insert(path, 1, start)
            return path
        end
    end
    return nil  -- No path
end

-- Example Graph
local graph = {
    A = {B=4, C=2},
    B = {D=5, E=10},
    C = {B=1, D=8},
    D = {E=2},
    E = {}
}

-- Run Dijkstra
local dist, prev = dijkstra(graph, "A")

-- Print Results
print("Shortest Distances from A:")
for node, d in pairs(dist) do
    print(node .. ": " .. d)
end

print("\nPaths from A:")
for node in pairs(graph) do
    local path = getPath(prev, "A", node)
    if path then
        print(node .. ": " .. table.concat(path, " → "))
    end
end
