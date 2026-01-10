--table_helper.lua
local function flatten(...)
    local result = {}
    for _, list in ipairs({...}) do
        for _, item in ipairs(list) do
            table.insert(result, item)
        end
    end
    return result
end

local function mergeTables(...)
    local merged = {}
    for _, tbl in pairs({...}) do
        for key, value in pairs(tbl) do
            merged[key] = value
        end
    end
    return merged
end

-- Returns the record table if found, or nil if not found
function selectRecordById(table, id)
    if not table or not id then return nil end

    id = tostring(id)

    for _, record in ipairs(table) do
        -- Use rawget to avoid __index metamethod (and potential loops)
        local record_id = rawget(record, "id")

        -- If no id field at all, skip safely
        if record_id ~= nil then
            if tostring(record_id) == id then
                return record
            end
        end
    end

    return nil
end

local function updateRecordById(table, id, property, value)
-- Ensure id is a string (in case something passes a number by mistake)
    id = tostring(id)

    for i, record in ipairs(table) do
        if record.id == id then
            record[property] = value
            return true
        end
    end
    return false
end

-- Helper for table.contains (Lua doesn't have it built-in)
local function containsKey(t, key)
    return t[key] ~= nil
end

local function containsValue(t, value)
    if t == nil then return false end
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local function tryGetValue(t, value)
    if t == nil then return nil end
    
    for k, v in pairs(t) do
        if v == value then
            return k, v  -- found: return both key and value
        end
    end
    
    return nil  -- not found
end

local function findKeyForValue(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

return { containsKey = containsKey
, containsValue = containsValue
, tryGetValue = tryGetValue
, findKeyForValue = findKeyForValue
, flatten = flatten
, mergeTables = mergeTables
, selectRecordById = selectRecordById
, updateRecordById = updateRecordById }
