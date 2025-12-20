-- ResourceBar.lua - HP, Mana, Stamina Manager
local ResourceBar = {}
ResourceBar.__index = ResourceBar

-- Constructor with TYPE CHECKING!
function ResourceBar:new(progress_bar)
    -- VALIDATE: Must be ResourceBar or nil
    if progress_bar and getmetatable(progress_bar) ~= ResourceBar then
        error("progress_bar must be a ResourceBar!")
    end
    
    local self = setmetatable({
        _val = progress_bar and progress_bar._val or {
            current = 0,
            maximum = 100,  -- Default max
            regen = 0,
            regen_percentage = 0,
            differential = 0,
            differential_percentage = 0
        }
    }, ResourceBar)
    
    return self
end

-- GAIN (positive differential)
function ResourceBar:gain(amount)
    if amount > 0 then
        self._val.differential = amount
    end
end

-- GAIN % of MAX
function ResourceBar:gain_percentage(percentage)
    if percentage > 0 then
        self._val.differential_percentage = percentage
    end
end

-- DAMAGE (negative differential)
function ResourceBar:subtract(amount)
    if amount > 0 then
        self._val.differential = -amount
    end
end

-- DAMAGE % of MAX
function ResourceBar:subtract_percentage(percentage)
    if percentage > 0 then
        self._val.differential_percentage = -percentage
    end
end

-- SET REGEN (flat)
function ResourceBar:set_regen(regen)
    self._val.regen = regen or 0
end

-- SET REGEN % of MAX
function ResourceBar:set_regen_percentage(percentage)
    self._val.regen_percentage = percentage or 0
end

-- TICK: Apply regen + differential
function ResourceBar:tick()
    local v = self._val
    
    -- Apply REGEN
    v.current = v.current + v.regen
    v.current = v.current + (v.maximum * v.regen_percentage / 100)

    -- REGEN does not go above maximum
    if v.current >= v.maximum then
        v.current = v.maximum
    end
    
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

-- READ-ONLY ACCESSORS
function ResourceBar:current() return self._val.current end
function ResourceBar:maximum() return self._val.maximum end
function ResourceBar:percentage() 
    return self._val.maximum > 0 and (self._val.current / self._val.maximum * 100) or 0 
end

-- SET MAXIMUM
function ResourceBar:set_maximum(max, set_current)
    self._val.maximum = max or 100
    if set_current ~= nil then
        self._val.current = max or 100
    end
end

-- PROTECT: Read-only public interface
local mt = {
    __index = ResourceBar,
    __newindex = function(self, k, v)
        error("ResourceBar is READ-ONLY! Use :gain(), :subtract(), etc.")
    end
}

-- Apply to ALL instances
setmetatable(ResourceBar, mt)

return ResourceBar

