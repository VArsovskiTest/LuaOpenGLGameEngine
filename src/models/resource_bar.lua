-- resource_bar.lua

local guid_generator = require("helpers.guid_helper")

local ResourceBar = {}
ResourceBar.__index = ResourceBar

-- Helper: Creates internal data table (writable only from inside the class)
local function createResourceData(name, maximum, current)
    return {
        id = guid_generator.generate_guid(),
        name = name or "Unnamed",
        current = current or 0,
        maximum = maximum or 100,
        regen = 0,                    -- flat per second
        regen_percentage = 0,         -- % of max per second
        differential = 0,             -- one-shot flat change
        differential_percentage = 0   -- one-shot % of max change
    }
end

-- Constructor
function ResourceBar:new(name, maximum, current)
    local self = createResourceData(name, maximum, current)
    self.__index = ResourceBar -- Make all the Class methods in tick(), set_maximum() e.t.c. publicly available
    local instance = {
        -- Public read-only view (we protect the instance, not the data)
        _data = self,     -- internal writable reference
        type = "resource_bar"
    }

    -- Protect instance from accidental field addition/modification from outside
    return setmetatable(instance, {
        __index = ResourceBar,
        __newindex = function(t, key, value)
            error("ResourceBar instances are read-only from outside. " ..
                  "Use proper methods (gain, subtract, set_regen, etc.)", 2)
        end
    })
end

-- Convenience alias (common pattern)
function ResourceBar.create(name, maximum, current)
    return ResourceBar:new(name, maximum, current)
end

-- ────────────────────────────────────────────────────────────────
-- Tick - called ~once per second (or with dt)
-- ────────────────────────────────────────────────────────────────
-- function ResourceBar:tick(dt)
--     dt = dt or 1   -- default: full second

--     local v = self._data

--     -- 1. Continuous regeneration (scaled by time)
--     local regen_this_tick = (v.regen + v.maximum * v.regen_percentage / 100) * dt
--     v.current = v.current + regen_this_tick

--     -- 2. Apply pending one-shot changes
--     v.current = v.current + v.differential
--     v.current = v.current + (v.maximum * v.differential_percentage / 100)

--     -- 3. Reset one-shot accumulators
--     v.differential = 0
--     v.differential_percentage = 0

--     -- 4. Clamp
--     v.current = math.max(0, math.min(v.current, v.maximum))
-- end

-- TICK: Apply regen + differential
function ResourceBar:tick()
    local v = self._data or {}

    -- Apply REGEN
    v.current = v.current + v.regen
    v.current = v.current + (v.maximum * v.regen_percentage / 100)
    
    -- Apply DIFFERENTIAL %
    if v.differential_percentage ~= 0 then
        v.current = v.current + (v.maximum * v.differential_percentage / 100)
        v.differential_percentage = 0  -- Reset
    end
    
    -- Apply DIFFERENTIAL flat
    if v.differential ~= 0 then
        v.current = v.current + v.differential
        v.differential = 0  -- Reset
    end
    
    -- Clamp 0 to maximum
    v.current = math.max(0, math.min(v.current, v.maximum))
end

-- ────────────────────────────────────────────────────────────────
-- Public interface - mutation methods
-- ────────────────────────────────────────────────────────────────

function ResourceBar:gain(amount)
    if amount > 0 then
        self._data.differential = self._data.differential + amount
    end
end

function ResourceBar:gain_percentage(percentage)
    if percentage > 0 then
        self._data.differential_percentage = self._data.differential_percentage + percentage
    end
end

function ResourceBar:subtract(amount)
    if amount > 0 then
        self._data.differential = self._data.differential - amount
    end
end

function ResourceBar:subtract_percentage(percentage)
    if percentage > 0 then
        self._data.differential_percentage = self._data.differential_percentage - percentage
    end
end

function ResourceBar:set_regen(flat_per_second)
    self._data.regen = flat_per_second or 0
end

function ResourceBar:set_regen_percentage(percent_of_max_per_second)
    self._data.regen_percentage = percent_of_max_per_second or 0
end

function ResourceBar:set_maximum(value, also_set_current)
    self._data.maximum = value or 100
    if also_set_current then
        self._data.current = self._data.maximum
    end
end

    -- ────────────────────────────────────────────────────────────────
    -- Read-only getters
    -- ────────────────────────────────────────────────────────────────
    function ResourceBar:id()          return self._data.id end
    function ResourceBar:name()        return self._data.name end
    function ResourceBar:current()     return self._data.current end
    function ResourceBar:maximum()     return self._data.maximum end
    function ResourceBar:percentage()
        if self._data.maximum <= 0 then return 0 end
        return (self._data.current / self._data.maximum) * 100
    end

-- return setmetatable(ResourceBar, {
--         __index = ResourceBar,
--     __newindex = function(t, key, value)
--         error("ResourceBar instances are read-only from outside. " ..
--                 "Use proper methods (gain, subtract, set_regen, etc.)", 2)
--     end
-- })

return ResourceBar
