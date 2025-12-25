local function setup_paths()
    local info   = debug.getinfo(1, "S")
    local script = info.source:sub(1,1) == "@" and info.source:sub(2) or "test_init.lua"
    local dir = script:match("^(.*[\\/])")
    
    -- Go up from src/tests/ → project root
    local root = dir:match("^(.*)/src/tests/") or "."
    _G.ROOT = root

    local paths = {
        root .. "/src/?.lua",
        root .. "/src/?/init.lua",
        root .. "/src/commands/?.lua",
        root .. "/src/engines/?.lua",
        root .. "/src/enums/?.lua",
        root .. "/src/helpers/?.lua",
        root .. "/src/mocks/?.lua",
        root .. "/src/models/?.lua",        
        root .. "/src/scripts/?.lua",
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

    -- Add WSL local LuaRocks modules to package.path (for Windows Lua accessing WSL files)
    -- local wsl_rocks_path = [[\\wsl$\Ubuntu\home\vicko\.luarocks\share\lua\5.4\?.lua]]
    -- local wsl_rocks_init = [[\\wsl$\Ubuntu\home\vicko\.luarocks\share\lua\5.4\?\init.lua]]
    -- package.path = package.path .. ";" .. wsl_rocks_path .. ";" .. wsl_rocks_init
    -- local wsl_cpath = [[\\wsl$\Ubuntu\home\vicko\.luarocks\lib\lua\5.4\?.so]]
    -- package.cpath = package.cpath .. ";" .. wsl_cpath
    -- package.path = package.path .. ";\\\\wsl$\\Ubuntu\\home\\vicko\\.luarocks\\share\\lua\\5.4\\?.lua"

    -- Add C:\lua5.4 to package.path and package.cpath
    local lua54_path = "C:\\lua5.4"   -- use double backslashes in Lua strings
    -- For .lua modules (e.g., redis.lua)
    package.path = package.path .. ";" .. lua54_path .. "\\?.lua;" .. lua54_path .. "\\?\\init.lua"
    -- For .dll C extensions (e.g., socket/core.dll, cjson.dll)
    package.cpath = package.cpath .. ";" .. lua54_path .. "\\?.dll;" .. lua54_path .. "\\clibs\\?.dll"

    local ok, redis_mod = pcall(require, "redis")
    if ok then
        print("redis loaded successfully from C:\\lua5.4")
        if redis_mod._VERSION then
            print("redis version:", redis_mod._VERSION)
        end
    else
        print("Failed to load redis:", redis_mod)
    end

    -- Print current package paths for debugging
    print("Current package.path:\n" .. package.path)
end

return { setup_paths = setup_paths }
