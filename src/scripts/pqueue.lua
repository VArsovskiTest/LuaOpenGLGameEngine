--pqueue.lua
local PQueue = {}

local ti = table.insert
local tr = table.remove
local tr2 = function(t,v)
    for i = 1,#t do
        if t[i]==v then
            tr(t,i)
            break
        end
    end
end

function PQueue.new()
    local t={}
    local set={}
    local r_set={}
    local keys={}

    local addKV = function(k,v)
        set[k]=v
        if not r_set[v] then
            ti(keys,v)
            table.sort(keys)
            local k0={k}
            r_set[v]=k0
            setmetatable(k0, {__mode='v'})
        else
            ti(r_set[v],k)
        end
    end

    t.addKV = addKV

    local remove = function(k)
        local v = set[k]
        local prioritySet = r_set[v]
        tr2(prioritySet, k)
        if #prioritySet < 1 then
            tr2(keys, v)
            r_set[v] = nil
            table.sort(keys)
            set[k]=nil
        end
    end
    t.remove = remove

    t.min = function()
        local priority = keys[1]
        if priority then
            return r_set[priority][1] or {}
        else
            return {}
        end
    end

    t.max = function()
    local priority = keys[#keys]
        if priority then
            return r_set[priority][1] or {}
        else
            return {}
        end
    end

    t.empty = function()
        return #keys < 1
    end

    t.iterator = function()
        return function()
            if not t.empty() then
                local element = t.max()
                t.remove(element)
                return element
            end
        end
    end

    setmetatable(t, {__index = set,
        __newindex = function(t,k,v)
            if not set[k] then
                addKV(k, v)
            else
                remove(k)
                addKV(k, v)
            end
        end
    })
    return t
end

return PQueue
