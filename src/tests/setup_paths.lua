-- tests/setup_paths.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local this_dir = this_file:match("^(.*)/") or "."
local root = this_dir:match("^(.*)/tests$") or this_dir:match("^(.*)/tests/") or this_dir

local function add(p)
    p = p:gsub("\\", "/"):gsub("//+", "/")
    if not package.path:find(p:gsub("([%.%+%-%?])", "%%%1"), 1, true) then
        package.path = package.path .. ";" .. p
    end
end

add(root .. "/src/?.lua")
add(root .. "/src/enums/?.lua")
add(root .. "/src/ai/?.lua")
add(root .. "/tests/?.lua")           -- THIS ADDS ./tests — CRITICAL FOR require("test_init")
add(root .. "/tests/?/init.lua")      -- for require("helpers")
add(root .. "/tests/helpers/?.lua")
