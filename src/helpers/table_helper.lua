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

-- Returns the record table if found, or nil if not found
function selectRecordById(table, id)
-- Ensure id is a string (in case something passes a number by mistake)
    id = tostring(id)

    for _, record in ipairs(table) do
        if record.id == id then
            return record
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

return { flatten = flatten, selectRecordById = selectRecordById, updateRecordById = updateRecordById }
