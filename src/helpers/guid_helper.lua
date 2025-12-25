-- Simple RFC4122 v4 GUID generator (random-based)
local function generate_guid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local chars = "0123456789abcdef"

    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

local function initialize_guid_generation()
    math.randomseed(os.time())
    for i = 1, 10 do math.random() end -- Warm up
end

return { generate_guid = generate_guid, initialize_guid_generation = initialize_guid_generation }
