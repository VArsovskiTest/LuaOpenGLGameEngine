-- debugger.lua

local function require_with_traceback(module)
    local status, result = pcall(require, module)
    if not status then
        print("Error requiring module:", module)
        print(result)
        debug_traceback()
    else
        return result
    end
end

local function debug_traceback()
    local level = 1
    while true do
        local info = debug.getinfo(level, "nSl")
        if not info then break end
        if info.what == "C" then
            print(string.format("C function: %s", info.namewhat))
        else
            local args = {}
            local arg_count = info.nparams
            for i = 1, arg_count do
                local name, value = debug.getlocal(level, i)
                table.insert(args, string.format("%s = %s", name, tostring(value)))
            end
            print(string.format("File: %s, Line: %d, Function: %s(%s)", info.short_src, info.currentline, info.name, table.concat(args, ", ")))
        end
        level = level + 1
    end
end

-- Check if a module name is provided as a command-line argument
if #arg < 1 then
    print("Usage: lua debugger.lua <module_name>")
    os.exit(1)
end

-- Get the module name from the command-line arguments
local module_name = arg[1]

-- Require the specified module and capture any errors
local other_script = require_with_traceback(module_name)

-- If the other script loaded successfully, you can use it here
if other_script then
    print(module_name .. " loaded successfully")
    -- Call functions or access variables from other_script
end
