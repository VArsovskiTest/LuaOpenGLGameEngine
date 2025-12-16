-- src/tests/test_init.lua
-- Final version – NO infinite loop, perfect paths, working debugger

----------------------------------------------------------------
-- 1. Path setup – fixes require("enums.attack_types") forever
----------------------------------------------------------------
-- do
--     local info   = debug.getinfo(1, "S")
--     local script = info.source:sub(1,1) == "@" and info.source:sub(2) or "test_init.lua"
--     local dir    = script:match("(.*/)")

--     -- Go up from src/tests/ → project root
--     local root = dir:match("^(.*)/src/tests/") or "."
--     _G.ROOT = root

--     local paths = {
--         root .. "/src/?.lua",
--         root .. "/src/?/init.lua",           -- makes require("enums.attack_types") work
--         root .. "/src/enums/?.lua",
--         root .. "/src/tests/?.lua",
--         root .. "/src/tests/?/init.lua",
--         root .. "/src/tests/helpers/?.lua",
--     }

--     if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
--         -- Add paths for the debugger
--         local cwd = arg[0]:match("(.*/)")
--         if cwd then
--             package.path = package.path .. ";" .. cwd .. "?.lua"
--             package.path = package.path .. ";" .. cwd .. "?/init.lua"
--         end
--     end

--     for _, p in ipairs(paths) do
--         p = p:gsub("//+", "/")
--         if not package.path:find(p:gsub("([%.%+%-%?])", "%%%1"), 1, true) then
--             package.path = package.path .. ";" .. p
--         end
--     end

--     print("Current package.path:\n" .. package.path)
-- end

print("Current directory:", os.execute("cd"))
local function initializePaths()
    local info   = debug.getinfo(1, "S")
    local script = info.source:sub(1,1) == "@" and info.source:sub(2) or "test_init.lua"
    local dir = script:match("^(.*[\\/])")
    
    -- Go up from src/tests/ → project root
    local root = dir:match("^(.*)/src/tests/") or "."
    _G.ROOT = root

    local paths = {
        root .. "/src/?.lua",
        root .. "/src/?/init.lua",
        root .. "/src/enums/?.lua",
        root .. "/src/tests/?.lua",
        root .. "/src/tests/?/init.lua",
        root .. "/src/tests/helpers/?.lua"
    }

    for _, p in ipairs(paths) do
        p = p:gsub("//+", "/")

        -- Avoid adding duplicates
        if not package.path:find(p:gsub("([%.%+%-%?])", "%%%1"), 1, true) then
            package.path = package.path .. ";" .. p
        end
    end

    -- Print current package paths for debugging
    print("Current package.path:\n" .. package.path)
end

-- Initialize paths when this script is loaded
initializePaths()

----------------------------------------------------------------
-- 2. Debugger (only when launched from VS Code)
----------------------------------------------------------------
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    local ok, mod = pcall(require, "lldebugger")
    if ok and mod and mod.start then
        mod.start()
        print("Debugger attached – breakpoints active!")
    end
end

----------------------------------------------------------------
-- 3. Load helpers once
----------------------------------------------------------------
-- local h = require("helpers")
-- _G.h = h
-- before_each = h.reset

----------------------------------------------------------------
-- 
-- 4. Tiny test framework (unchanged)
------------------------------------------------------------------
local PASS, FAIL = 0, 0
local current_before_each = nil     -- ← NEW
local function c(code, str) return os.getenv("NO_COLOR") and str or ("\27["..code.."m"..str.."\27[0m") end

describe = function(name, fn)
    print("\n"..c("1;36", "━━ "..name.." ━━"))
    pcall(fn)
end

before_each = function(fn)          -- ← NEW
    current_before_each = fn
end

it = function(name, fn)
    io.write(c("37", "  • "..name.." "))
    
    if current_before_each then
        local ok, err = pcall(current_before_each)
        if not ok then
            FAIL = FAIL + 1
            print(c("31", "FAIL"))
            print(c("31", "    before_each failed: "..tostring(err):gsub("^.-:%d+: ", "")))
            return
        end
    end
    
    local ok, err = pcall(fn)
    if ok then PASS = PASS + 1 print(c("32", "PASS"))
    else FAIL = FAIL + 1 print(c("31", "FAIL")) print(c("31", "    "..tostring(err):gsub("^.-:%d+: ", ""))) end
end

expect = function(v) return { to_equal = function(e) assert(v == e, "expected "..tostring(e)..", got "..tostring(v)) end } end

----------------------------------------------------------------
-- 5. Summary
----------------------------------------------------------------
local function summary()
    print("\n"..c("37", string.rep("─", 60)))
    if FAIL == 0 then print(c("1;32", "ALL "..PASS.." TESTS PASSED!"))
    else print(c("1;31", PASS.." passed, "..FAIL.." failed")) os.exit(1) end
end

if not _G._TESTED then
    _G._TESTED = true
    local old_dofile = dofile
    dofile = function(f, ...)
        local r = old_dofile(f, ...)
        if f and f:match("test_.*%.lua$") then summary() end
        return r
    end
end

----------------------------------------------------------------
-- 6. Bootstrap game (only ONCE)
----------------------------------------------------------------
if not _G.GAME_BOOTSTRAPPED then
    require("game")
    initGame()
    _G.GAME_BOOTSTRAPPED = true
end

print(c("90", "Test framework ready! Root: ".._G.ROOT))

-- Run the test(s)
if arg and arg[1] then
    dofile(arg[1])
-- else
--     dofile("./run_all_tests.lua")
end
