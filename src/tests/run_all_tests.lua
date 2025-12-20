-- tests/run_all_tests.lua
dofile("test_init.lua")

local function run(file)
    print("\nRunning " .. file)
    local ok, err = pcall(dofile, file)
    if not ok then print("Failed: " .. err) end
    return ok
end

local tests = {}
for line in io.popen('find tests -name "test_*.lua" -type f 2>/dev/null || dir /s /b tests\\*test_*.lua 2>nul'):lines() do
    line = line:gsub("\\", "/")
    if not line:find("test_init.lua") then
        table.insert(tests, line)
    end
end

table.sort(tests)
local passed = 0
for _, t in ipairs(tests) do if run(t) then passed = passed + 1 end end

print("\n" .. ("="):rep(60))
print(("%d / %d test files passed"):format(passed, #tests))
if passed == #tests then
    print("ALL TESTS PASSED!")
else
    os.exit(1)
end
