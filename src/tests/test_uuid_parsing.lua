-- Paste the function first:
function extract_uuid(s)
    if type(s) ~= "string" or s == "" then
        return nil
    end

    -- Try to match UUID followed by colon + number (most common in your logs)
    local uuid = s:match("([0-9a-fA-F%-]+)%s*:%s*%d+")
    if uuid then
        -- Quick basic validation (36 chars with 4 hyphens)
        if #uuid == 36 and uuid:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
            return uuid:lower()
        end
    end

    -- Fallback: just find first valid-looking UUID in the string
    uuid = s:match("[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]%-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]")
    if uuid then
        return uuid:lower()
    end

    return nil
end

-- Test cases
local test_cases = {
    { "[2026-01-22 16:11:41] entity_id: a96ed224-c973-4d8a-98a4-f3e2d1063548: 1310898462",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "id: a96ed224-c973-4d8a-98a4-f3e2d1063548: 1310898462",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "uuid: a96ed224-c973-4d8a-98a4-f3e2d1063548",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "a96ed224-c973-4d8a-98a4-f3e2d1063548",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "A96ED224-C973-4D8A-98A4-F3E2D1063548:999999",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "prefix a96ed224-c973-4d8a-98a4-f3e2d1063548 suffix",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },

    { "entity_id: abb2e458-b09f-43c4-95ea-35e73d0dac7c: 1945088879",
      "abb2e458-b09f-43c4-95ea-35e73d0dac7c" },

    { "no uuid here", nil },

    { "", nil },

    { "123e4567-e89b-12d3-a456-426614174000 extra text :123",
      "123e4567-e89b-12d3-a456-426614174000" },

    { "multiple uuids a96ed224-c973-4d8a-98a4-f3e2d1063548:111  and 550e8400-e29b-41d4-a716-446655440000",
      "a96ed224-c973-4d8a-98a4-f3e2d1063548" },  -- takes first match after :number, else first
}

print("=== extract_uuid tests ===\n")

local all_pass = true

for i, tc in ipairs(test_cases) do
    local input    = tc[1]
    local expected = tc[2]
    local result   = extract_uuid(input)

    local passed = (result == expected) or (result == nil and expected == nil)

    print(string.format("Test %2d: %s", i, passed and "PASS" or "FAIL"))

    if not passed then
        all_pass = false
        print("  Input:    " .. tostring(input))
        print("  Expected: " .. tostring(expected))
        print("  Got:      " .. tostring(result))
        print()
    end
end

if all_pass then
    print("\nALL TESTS PASSED ✓")
else
    print("\nSome tests FAILED ✗")
end
