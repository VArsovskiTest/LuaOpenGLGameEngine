-- Binary Heap Priority Queue (Min-Heap)
local bheap = {}
bheap.__index = bheap

-- Create new heap
function bheap.new()
    return setmetatable({heap = {0}, priorities = {}}, bheap)  -- [0] = sentinel
end

-- Add item with priority (key, priority)
function bheap:add(key, priority)
    local h = self.heap
    local p = self.priorities
    
    -- Add to end
    h[#h + 1] = key
    p[key] = priority
    
    -- Bubble up
    self:_bubbleUp(#h)
end

-- Get/remove MIN priority item
function bheap:pop()
    if #self.heap == 1 then return nil end
    
    local h = self.heap
    local minKey = h[1]
    local minPri = self.priorities[minKey]
    
    -- Move last to root
    h[1] = h[#h]
    self.priorities[h[1]] = self.priorities[h[#h]]
    h[#h] = nil
    
    -- Sink down
    self:_sinkDown(1)
    
    self.priorities[minKey] = nil
    return minKey
end

-- Peek min WITHOUT removing
function bheap:peek()
    return #self.heap > 1 and self.heap[1] or nil
end

-- Is empty?
function bheap:empty()
    return #self.heap == 1
end

-- Size
function bheap:size()
    return #self.heap - 1
end

-- PRIVATE: Bubble up (after add)
function bheap:_bubbleUp(i)
    local h = self.heap
    local p = self.priorities
    local parent = math.floor(i / 2)
    
    while i > 1 and p[h[i]] < (p[h[parent]] or -1) do
        h[i], h[parent] = h[parent], h[i]
        i = parent
        parent = math.floor(i / 2)
    end
end

-- PRIVATE: Sink down (after pop)
function bheap:_sinkDown(i)
    local h = self.heap
    local p = self.priorities
    local size = #h - 1
    
    while true do
        local left = 2 * i
        local right = 2 * i + 1
        local smallest = i
        
        -- Find smallest child
        if left <= size and p[h[left]] < p[h[smallest]] then
            smallest = left
        end
        if right <= size and p[h[right]] < p[h[smallest]] then
            smallest = right
        end
        
        if smallest == i then break end
        
        h[i], h[smallest] = h[smallest], h[i]
        i = smallest
    end
end

-- Iterator (yields min first)
function bheap:iterator()
    local heap = self
    return function()
        return heap:pop()
    end
end

-- Remove SPECIFIC key (O(n) worst case)
function bheap:remove(key)
    -- Find index, swap with last, bubble/sink
end

-- Change priority of existing key
function bheap:change(key, newPriority)
    self.priorities[key] = newPriority
    -- Re-heapify
end

-- Max-Heap (flip priorities)
function bheap.newMax()
    local h = bheap.new()
    h._max = true
    return h
end

return bheap
