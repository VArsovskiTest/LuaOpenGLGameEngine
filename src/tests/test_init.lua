-- src/tests/test_init.lua
local setup = require("src.setup.setup_paths")
setup.setup_paths()

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
-- 
-- 3. Tiny test framework (unchanged)
------------------------------------------------------------------
local PASS, FAIL = 0, 0
local current_before_each = nil
local current_after_each = nil
local function c(code, str) return os.getenv("NO_COLOR") and str or ("\27["..code.."m"..str.."\27[0m") end

describe = function(name, fn)
    print("\n"..c("1;36", "━━ "..name.." ━━"))
    pcall(fn)
end

before_each = function(fn)
    current_before_each = fn
end

local function after_each(fn)
    current_after_each = fn
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

    -- if current_after_each then
    --     local ok2, err2 = pcall(current_after_each)
    --     if not ok2 then
    --         FAIL = FAIL + 1
    --         print(c("31", "\nFAIL (in after_each)"))
    --         print(c("31", "      " .. tostring(err2):gsub("^[^:]+:%d+:%s*", "")))
    --     end
    -- end

    if ok then PASS = PASS + 1 print(c("32", "PASS"))
    else
        FAIL = FAIL + 1
        local clean_err = tostring(err):gsub("^.*\\LuaOpenGLGameEngine\\src[\\/]?", "")
        print(c("31", "    " .. clean_err))
        -- print(c("31", "FAIL")) print(c("31", "    " .. tostring(err):gsub("^[^:]+:%d+:%s*", "")))
    end
end

-- utils/expect.lua  (or just paste at the top of your test files)

local PASS = 0
local FAIL = 0

-- Optional: simple color helper (if you have it)
local function c(code, text)
    return "\27[" .. code .. "m" .. text .. "\27[0m"
end

-- Main expect function
local function expect(value)
    return {
        -- Equality
        to_equal = function(expected)
            -- print("DEBUG: type of value =", type(value))
            -- print("DEBUG: value =", value)
            -- print("DEBUG: type of expected =", type(expected))
            -- print("DEBUG: expected =", expected)

            if value == expected then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected: " .. tostring(expected)))
                print(c("31", "    but got:  " .. tostring(value)))
            end
        end,

        -- Nil checks
        to_be_nil = function()
            if value == nil then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected nil, but got: " .. tostring(value)))
            end
        end,

        not_nil = function()
            if value ~= nil then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected value not to be nil, but it was nil"))
            end
        end,

        -- Truthiness
        to_be_truthy = function()
            if value then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected truthy value, but got: " .. tostring(value)))
            end
        end,

        to_be_falsy = function()
            if not value then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected falsy value, but got: " .. tostring(value)))
            end
        end,

        to_be_greater_than = function(num)
            if type(value) == "number" and value > num then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected " .. tostring(value) .. " > " .. tostring(num)))
            end
        end,

        to_be_less_than = function(num)
            if type(value) == "number" and value < num then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected " .. tostring(value) .. " < " .. tostring(num)))
            end
        end,

        -- Table / string containment
        to_contain = function(sub)
            local value_type = type(value)
            local found = false

            if value_type == "table" then
                for _, v in ipairs(value) do
                    if v == sub then found = true; break end
                end
            elseif value_type == "string" then
                if value:find(sub, 1, true) then found = true end
            end

            if found then
                PASS = PASS + 1
                print(c("32", "PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "FAIL"))
                print(c("31", "    expected " .. tostring(value) .. " to contain: " .. tostring(sub)))
            end
        end,

        -- Table Length check
        to_have_items = function(n)
            if type(value) == "table" and #value == n then
                PASS = PASS + 1
                print(c("32", "  PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "  FAIL"))
                print(c("31", "      expected table with " .. n .. " items, but had " .. tostring(#value)))
            end
        end,

        -- Exception handling
        to_throw = function(expected_msg_contains)
            if type(value) ~= "function" then
                FAIL = FAIL + 1
                print(c("31", "  FAIL"))
                print(c("31", "      to_throw() expected a function, got " .. type(value)))
                return
            end

            local success, err = pcall(value)
            if success then
                FAIL = FAIL + 1
                print(c("31", "  FAIL"))
                print(c("31", "      expected function to throw, but it succeeded"))
            elseif expected_msg_contains then
                if string.find(tostring(err), expected_msg_contains, 1, true) then
                    PASS = PASS + 1
                    print(c("32", "  PASS"))
                else
                    FAIL = FAIL + 1
                    print(c("31", "  FAIL"))
                    print(c("31", "      expected error containing: " .. expected_msg_contains))
                    print(c("31", "      but got: " .. tostring(err)))
                end
            else
                -- Any error is fine
                PASS = PASS + 1
                print(c("32", "  PASS"))
            end
        end,

        to_not_throw = function()
            if type(value) ~= "function" then
                FAIL = FAIL + 1
                print(c("31", "  FAIL"))
                print(c("31", "     to_not_throw() expected a function, got " .. type(value)))
                return
            end

            local success, err = pcall(value)

            if success then
                PASS = PASS + 1
                print(c("32", "  PASS"))
            else
                FAIL = FAIL + 1
                print(c("31", "  FAIL"))
                print(c("31", "     expected function to NOT throw, but it errored: " .. tostring(err)))
            end
        end
    }
end

-- Final summary
local function summary()
    print("\n" .. string.rep("=", 40))
    print(c("32", "PASS: " .. PASS))
    print(c("31", "FAIL: " .. FAIL))
    print(string.rep("=", 40))
    if FAIL == 0 then
        print(c("32", "All tests passed!"))
    else
        print(c("31", "Some tests failed."))
    end
end

-- Make available globally
_G.expect = expect
_G.summary = summary

----------------------------------------------------------------
-- 4. Summary
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
-- 5. Bootstrap game (only ONCE)
----------------------------------------------------------------

function bootstrap_game()
    if not _G.GAME_BOOTSTRAPPED then
        require("game")
        initGame()
        _G.GAME_BOOTSTRAPPED = true
    end

    print(c("90", "Test framework ready! Root: ".._G.ROOT))
end

-- -- Run the test(s)
-- if arg and arg[1] then
--     dofile(arg[1])
-- -- else
-- --     dofile("./run_all_tests.lua")
-- end

----------------------------------------------------------------
-- 6. Init MockEngine hook
----------------------------------------------------------------

local engine_modules = require("enums.engine_modules")
_G.EngineModules = engine_modules

_G.CommandQueue = require("commands.command_queue")
_G.CommandQueue:reset()

local function init(context)
    if context == _G.EngineModules.AI then
        _G.MockEngine = require("mocks.ai_mock_engine")
        print("TestInit: Initialized with AI Mock Engine.")
    elseif context == _G.EngineModules.COMMAND then
        _G.MockEngine = require("mocks.command_mock_engine")

        -- Subscribe enqueue and process events of _G.MockEngine globally:
        _G.MockEngine:subscribe("enqueue", function(c)
            print("command issued: ".. c)
        end)
        _G.MockEngine:subscribe("execute_immediately", function(c)
            print("command executed: ".. c)
        end)

        print("TestInit: Initialized with Command Mock Engine.")
    else
        error("TestInit: Unknown context provided: " .. tostring(context))
    end

    bootstrap_game()
end

print("=== Test Init Complete ===")
print("Globals available: Engine, MockEngine, CommandQueue")
print("Pre-seeded entities: 1001 and 1002")
print("Use dofile('tests/init_test.lua') at the start of any test file or runner\n")

-- Return the init function so other scripts can call it
return { init = init }
