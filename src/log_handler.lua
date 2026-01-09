-- log_handler.lua
local enableLogging = true
local logPath

local errorLogFile = nil
local logFile = nil

local unpack = unpack or table.unpack

if get_logs_path and enableLogging then
    logPath = get_logs_path("game_engine_log.txt")
end

-- Simple ANSI color helper (same as your c())
local function color(code, text)
    return "\27[" .. code .. "m" .. text .. "\27[0m"
end

-- Strips the file:line prefix from Lua error messages
local function clean_error_message(err)
    -- Remove things like "filename.lua:23: " at the start
    return tostring(err):gsub("^[^:]+:%d+:%s*", "")
end

local function log_error(msg)
    if not errorLogFile then return end
    errorLogFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. tostring(msg) .. "\n")
    errorLogFile:flush()
end

local function log_data(msg)
    if not logFile then return end
    logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. tostring(msg) .. "\n")
    logFile:flush()
end

-- Helper function to convert a table to a string for logging
local function serialize_table(t)
    if type(t) ~= 'table' then
        return tostring(t)
    end
    local s = '{ '
    for k, v in pairs(t) do
        s = s .. tostring(k) .. '=' .. serialize_table(v) .. ', '
    end
    return s .. '}\n'
end

-- The global error handler used by xpcall
local function global_error_handler(err)
    local clean_msg = clean_error_message(err)
    print(color("31", "ERROR"))
    print(color("31", "    " .. clean_msg))
    print(debug.traceback("", 2))

    log_error(clean_msg)
    log_error(debug.traceback("", 2))

    -- Optional: print full stack trace for debugging
    return clean_msg  -- returned value is passed to the second result of xpcall
end

function init_logging()
    if logFile then return end
    
    local path = get_logs_path("game_engine_log.txt")
    logFile = io.open(path, "a")
    if logFile then
        logFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] === Game Session Started ===\n")
        logFile:flush()
        print("Log initialized successfully at: " .. path)
    else
        print("FAILED to open log file: " .. path)
        print("Check permissions and path: " .. path)
    end
end

function init_error_logging()
    if errorLogFile then return end
    
    if (get_logs_path) then
        local path = get_logs_path("game_engine_errors.txt")
        errorLogFile = io.open(path, "a")
        if errorLogFile then
            errorLogFile:write("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] === Error logging Started ===\n")
            errorLogFile:flush()
            print("Error log initialized successfully at: " .. path)
        else
            print("FAILED to open log file: " .. path)
            print("Check permissions and path: " .. path)
        end
    end
end

-- Safe call wrapper — use this instead of direct function calls when you want protection
function safe_call(fn, ...)
    local args = {...}
    return xpcall(function()
        return fn(unpack(args))
    end, global_error_handler)
end

function assert_safe(condition, message)
    if not condition then
        error(message or "assertion failed!", 2)
    end
end

function with_retry(fn, max_attempts, delay_ms)
    max_attempts = max_attempts or 3
    delay_ms = delay_ms or 100  -- milliseconds

    local attempts = 0
    while attempts < max_attempts do
        attempts = attempts + 1

        local ok, result = pcall(fn)
        if ok then
            return true, result  -- success
        end

        -- On failure
        print(string.format("Attempt %d failed: %s", attempts, result))

        if attempts < max_attempts then
            if delay_ms > 0 then
                -- os.execute("sleep " .. delay_ms / 1000)  -- Unix
                os.execute("timeout /t " .. delay_ms / 1000) -- Win
            end
        end
    end

    return false, "All retry attempts failed"
end

function safe_call_with_retry(fn, max_attempts, delay_ms)
    max_attempts = max_attempts or 3

    for attempt = 1, max_attempts do
        local ok, result = safe_call(fn)
        if ok then
            return true, result
        end

        print(color("33", string.format("Retry %d/%d after error", attempt, max_attempts)))

        if attempt < max_attempts and delay_ms then
            -- os.execute("sleep " .. delay_ms / 1000)  -- Unix
            os.execute("timeout /t " .. delay_ms / 1000) -- Win
        end
    end

    return false, "Failed after retries"
end

function with_exponential_retry(fn, max_attempts, initial_delay_ms)
    initial_delay_ms = initial_delay_ms or 100
    max_attempts = max_attempts or 5

    local delay = initial_delay_ms

    for attempt = 1, max_attempts do
        local ok, result = pcall(fn)
        if ok then
            return true, result
        end

        print(string.format("Attempt %d/%d failed: %s", attempt, max_attempts, result))

        if attempt < max_attempts then
            os.execute("sleep " .. delay / 1000)
            delay = delay * 2  -- double delay each time
        end
    end

    return false, "Failed after " .. max_attempts .. " attempts"
end

print("=== Log Handler successfully initialized ===")

log_handler = {
    log_data = log_data,
    log_error = log_error,
    init_logging = init_logging,
    init_error_logging = init_error_logging,
    safe_call = safe_call,
    safe_call_with_retry = safe_call_with_retry,
}

return log_handler
