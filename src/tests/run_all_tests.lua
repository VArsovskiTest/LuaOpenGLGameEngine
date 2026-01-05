-- tests/run_all_tests.lua
-- Find the directory of THIS script
local info = debug.getinfo(1, "S")
local script_path = info.source
if script_path:sub(1,1) == "@" then
    script_path = script_path:sub(2)  -- remove leading @
end

local script_dir = script_path:match("^(.*[\\/])")
local tests_dir = script_dir  -- since run_all_tests.lua is inside tests/

print("Test runner directory:", tests_dir)

-- Helper: simple cross-platform dir listing fallback
local function list_test_files()
    local files = {}
    local cmd

    -- Detect OS
    local sep = package.config:sub(1,1)  -- "/" on Unix, "\\" on Windows
    local is_windows = sep == "\\"

    if is_windows then
        -- Windows: use dir in the known tests directory
        cmd = string.format('dir "%s\\test_*.lua" /b /s', tests_dir:sub(1, -2))  -- remove trailing slash
    else
        -- Unix/macOS/Linux
        cmd = string.format('find "%s" -name "test_*.lua" -type f', tests_dir:sub(1, -2))
    end

    local p = io.popen(cmd)
    if not p then
        error("Failed to run directory listing command: " .. cmd)
    end

    for line in p:lines() do
        line = line:gsub("\\", "/")
        -- Skip the runner and init files
        if not line:find("run_all_tests.lua") and not line:find("test_init.lua") then
            table.insert(files, line)
        end
    end
    p:close()

    return files
end

-- Load test_init.lua from the same directory
-- dofile(script_dir .. "test_init.lua")

local function run(file)
    print("\nRunning " .. file)
    local ok, err = pcall(dofile, file)
    if not ok then print("Failed: " .. err) end
    return ok
end

tests = list_test_files()
table.sort(tests)

if #tests == 0 then
    print("WARNING: No test files found! Searched in:", tests_dir)
    print("Make sure test files are named test_*.lua")
end

local cmd = is_windows 
    and string.format('dir "%stest_*.lua" /b', tests_dir)
    or string.format('ls "%stest_*.lua" 2>/dev/null', tests_dir:sub(1, -2))

for line in io.popen(cmd):lines() do
    print("test found: " .. line)
    table.insert(tests, tests_dir .. line)
end

local passed = 0
for _, t in ipairs(tests) do if run(t) then passed = passed + 1 end end

print("\n" .. ("="):rep(60))
print(("%d / %d test files passed"):format(passed, #tests))
if passed == #tests then
    print("ALL TESTS PASSED!")
else
    os.exit(1)
end
