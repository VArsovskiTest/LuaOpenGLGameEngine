-- tests/test_key_bindings.lua

require("../src/tests/test_init")
local Keyboard = require("keyboard")  -- Make sure paths are correct in your project
local KeyBindings = require("key_bindings")
local ActorActions = require("actor_actions")

-- Mock CommandQueue to track added commands
local mock_commands = {}
local CommandQueue = {
    enqueue = function(cmd)
        table.insert(mock_commands, cmd)
    end,
    clear = function()
        mock_commands = {}
    end
}

-- temporary for tests
local CommandQueue = CommandQueue
local ActorActions = ActorActions

-- Helper to simulate key press over frames
local function simulate_press(key)
    -- Frame 1: key down
    Keyboard.isPressed[key] = true
    Keyboard.update()
    -- Frame 2: key up (reset for next test)
    Keyboard.isPressed[key] = false
    Keyboard.update()
end

-- Reset everything before each test
local function reset_all()
    Keyboard.init()
    CommandQueue.clear()
    mock_commands = {}
    KeyBindings.bind_defaults()  -- Re-apply default bindings
end

print("\n=== KEY BINDINGS & INPUT SYSTEM TESTS ===\n")

describe("Keyboard basic edge detection", function()
    before_each(reset_all)

    it("should detect a single key press and fire handler once", function()
        local called = 0
        Keyboard.bind("1", function() called = called + 1 end)

        simulate_press("1")

        expect(called).to_equal(1, "Handler should be called exactly once on press")
    end)

    it("should NOT fire handler when key is held", function()
        local called = 0
        Keyboard.bind("space", function() called = called + 1 end)

        -- Press
        Keyboard.isPressed["space"] = true
        -- Hold (same frame state)
        Keyboard.update()
        Keyboard.update()
        Keyboard.update()
        -- Release
        Keyboard.isPressed["space"] = false
        Keyboard.update()

        expect(called).to_equal(1, "Handler should fire only once, not on hold")
    end)

    it("should support multiple different keys independently", function()
        local log = {}
        Keyboard.bind("q", function() table.insert(log, "q") end)
        Keyboard.bind("e", function() table.insert(log, "e") end)

        Keyboard.isPressed["q"] = true
        Keyboard.update()
        Keyboard.isPressed["q"] = false
        Keyboard.isPressed["e"] = true
        Keyboard.update()

        expect(#log).to_equal(2, "Both keys should fire")
        expect(log[1]).to_equal("q", "Keys should fire in correct order")
        expect(log[2]).to_equal("e", "Keys should fire in correct order")        
    end)
end)

describe("KeyBindings module - default bindings", function()
    before_each(reset_all)

    it("should bind movement keys and queue commands on press", function()
        simulate_press("w")
        simulate_press("s")
        simulate_press("a")

        expect(#mock_commands).to_equal(3, "Three movement commands should be queued")
        expect(mock_commands[1].name).to_equal("move_up")
        expect(mock_commands[2].name).to_equal("move_down")
        expect(mock_commands[3].name).to_equal("move_left")
    end)

    it("should bind number keys to potion slots", function()
        -- Assuming your ActionHandlers have potion1, potion2, etc.
        -- We'll spy on try_drink_potion_slot if it exists, or just check command count
        local original_try = _G.try_drink_potion_slot

        simulate_press("1")
        simulate_press("2")
        simulate_press("3")

        expect(#mock_commands).to_equal(3, "Potion slots 1-3 should be triggered")
        expect(mock_commands[1].name).to_equal("select_1")
        expect(mock_commands[2].name).to_equal("select_2")
        expect(mock_commands[3].name).to_equal("select_3")

        -- Restore
        _G.try_drink_potion_slot = original_try
    end)
end)

describe("KeyBindings reconfiguration", function()
    before_each(reset_all)

    it("should allow rebinding an action to a new key", function()
        -- Originally "w" → move_up
        simulate_press("w")
        expect(#mock_commands).to_equal(1, "#mock_commands queue not matching required length")
        expect(mock_commands[1].name).to_equal("move_up", "#mock_commands[1] does not match expected command name")

        CommandQueue.clear()

        -- Rebind move_up to "up" (or any key, e.g. "i")
        KeyBindings.bind_action("handle_move_up", "i")

        -- Old key "w" should do nothing now
        simulate_press("w")
        expect(#mock_commands).to_equal(0, "Old key 'w' should no longer trigger move_up")

        -- New key "i" should work
        simulate_press("i")
        expect(#mock_commands).to_equal(1, "#mock_commands queue not matching required length")
        expect(mock_commands[1].name).to_equal("move_up", "#mock_commands[1] does not match expected command name")
    end)

    it("should preserve other bindings when one is changed", function()
        KeyBindings.bind_action("handle_move_left", "q")

        simulate_press("q")  -- new left
        simulate_press("d")  -- old right should still work

        local names = {}
        for _, cmd in ipairs(mock_commands) do table.insert(names, cmd.name) end

        expect(#names).to_equal(2)
        expect(names).to_contain("move_left", "Does not contain 'move_left'!")
        expect(names).to_contain("move_right", "Does not contain 'move_right'!")
    end)
end)

describe("Edge cases & safety", function()
    before_each(reset_all)

    it("should not crash on unbound keys", function()
        expect(function()
            Keyboard.isPressed["undefined_key"] = true
            Keyboard.update()  -- Should not error
            Keyboard.isPressed["undefined_key"] = false
            Keyboard.update()
            -- assert(true, "Handling unknown keys should not crash")
        end).to_not_throw()
    end)

    it("should allow unbinding via bind_action with nil or invalid key", function()
        -- Some games allow disabling an action
        -- We'll just test that rebinding to unknown doesn't break
        KeyBindings.bind_action("handle_jump", "F15")  -- unlikely key

        simulate_press("space")  -- old jump key
        expect(#mock_commands).to_equal(0, "Old jump key should be unbound if fully reapplied")
    end)

    summary()
end)
