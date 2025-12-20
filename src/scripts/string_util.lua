-- string_util.lua

-- Utility function to serialize Lua objects to a JSON-like string
local function stringify(obj, indent, seen)
    indent = indent or 0
    seen = seen or {}
    local t = type(obj)

    -- Handle basic types
    if t == "nil" then return "null" end
    if t == "number" or t == "boolean" then return tostring(obj) end
    if t == "string" then return "\"" .. obj:gsub("\"", "\\\"") .. "\"" end

    -- Handle tables
    if t == "table" then
        -- Check for circular reference
        if seen[obj] then return "\"[circular]\"" end
        seen[obj] = true

        -- Safely get metatable without triggering __index
        local mt = rawget(getmetatable(obj) or {}, "__tostring") and getmetatable(obj)
        if mt and mt.__tostring then
            return "\"" .. tostring(obj) .. "\""
        end

        -- Build string representation
        local result = {}
        local indent_str = string.rep("  ", indent)
        table.insert(result, "{\n")

        -- Serialize table fields
        local first = true
        for k, v in pairs(obj) do
            if type(k) == "string" or type(k) == "number" then
                if not first then table.insert(result, ",\n") end
                first = false
                local key = type(k) == "string" and "\"" .. k .. "\"" or k
                table.insert(result, indent_str .. "  " .. key .. ": " .. stringify(v, indent + 1, seen))
            end
        end

        -- Indicate metatable if present, without recursing into it
        if mt then
            if not first then table.insert(result, ",\n") end
            table.insert(result, indent_str .. "  \"__metatable\": \"present\"")
        end

        table.insert(result, "\n" .. indent_str .. "}")
        return table.concat(result)
    end

    -- Fallback for other types (e.g., functions, userdata)
    return "\"" .. tostring(obj) .. "\""
end

-- Export the stringify function
return {
    stringify = stringify
}
