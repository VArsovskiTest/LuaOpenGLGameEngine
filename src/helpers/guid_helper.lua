-- Simple RFC4122 v4 GUID generator (random-based)
local function generate_uuid_v4()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local function random_hex()
        return string.format("%x", math.random(0, 15))
    end

    return (string.gsub(template, "[xy]", function(c)
        if c == "x" then
            return random_hex()
        else  -- "y"
            -- Variant: must be 8,9,a,b  →  binary 10xx
            local r = math.random(0, 3)   -- 0→8, 1→9, 2→a, 3→b
            return string.format("%x", 8 + r)
        end
    end))
end

local function initialize_guid_generation()
    math.randomseed(os.time())
    for i = 1, 10 do math.random() end -- Warm up
end

return { generate_guid = generate_uuid_v4, initialize_guid_generation = initialize_guid_generation }
