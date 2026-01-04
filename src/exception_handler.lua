-- utils/error_handler.lua or at top of your main file

-- Simple ANSI color helper (same as your c())
local function color(code, text)
    return "\27[" .. code .. "m" .. text .. "\27[0m"
end

-- Strips the file:line prefix from Lua error messages
local function clean_error_message(err)
    -- Remove things like "filename.lua:23: " at the start
    return tostring(err):gsub("^[^:]+:%d+:%s*", "")
end

-- The global error handler used by xpcall
local function global_error_handler(err)
    local clean_msg = clean_error_message(err)
    print(color("31", "ERROR"))
    print(color("31", "    " .. clean_msg))
    -- Optional: print full stack trace for debugging
    -- print(debug.traceback("", 2))
    return clean_msg  -- returned value is passed to the second result of xpcall
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
                os.execute("sleep " .. delay_ms / 1000)  -- Unix
                -- On Windows: os.execute("timeout /t " .. delay_ms / 1000)
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
            os.execute("sleep " .. delay_ms / 1000)
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
