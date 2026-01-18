-- tests/test_command_queue.lua

local init = require("../src/tests/test_init")
init.init(_G.EngineModules.COMMAND)

local BaseCommand = require("commands.base_command")
local CommandQueue = require("commands.command_queue")
local MoveToCommand = require("commands.move_to_command")

local mock_command_type_identifier = "mock_command"
local mock_component_name = "Position"

-- Helper: Dummy command factory for generic queue tests
local function create_dummy_command(entity_id, command_queue_name, component_name, payload, custom_execute)
    command_queue_name = command_queue_name or "DummyCommands"
    payload = payload or {}
    
    local cmd = BaseCommand:new(entity_id, mock_command_type_identifier, command_queue_name, component_name, payload)
    
    cmd.was_executed = false
    cmd.engine_received = nil
    
    -- Override execute (subclass-style implementation)
    cmd.execute = function(self, engine, entry)
        self.was_executed = true
        self.engine_received = engine
        if custom_execute then
            custom_execute(self, engine)  -- Pass self and engine (adjust if custom_execute needs entry)
        end
        -- REMOVED: BaseCommand._call_execute(...) – this caused the loop
    end
    return cmd
end

local initial_pos = { { x = 0, y = 0 }, { x = 0, y = 0 } }

describe("Generic command Queue Tests", function()
    before_each(function()
        CommandQueue:reset()
        _G.MockEngine:Reset()
        entity = _G.MockEngine:CreateEntity("entities", "Position_Commands")
        entity = _G.MockEngine:CreateEntity("entities", "JumpActions")
        entity = _G.MockEngine:CreateEntity("entities", "AttackActions")
        entity = _G.MockEngine:CreateEntity("entities", "InstantCast")        
        
        _G.MockEngine:AddComponent(entity.id, "Position_Commands", "Position", initial_pos)
        _G.MockEngine:AddComponent(entity.id, "JumpActions", "Position", initial_pos)
        _G.MockEngine:AddComponent(entity.id, "AttackActions", "Position", initial_pos)
        _G.MockEngine:AddComponent(entity.id, "InstantCast", "Position", initial_pos)
    end)

    it("Test 1: Enqueue + get_next_pending + process_next", function()
        local cmd1 = create_dummy_command(entity.id, "Position_Commands", mock_component_name, { user = "player1" })
        CommandQueue:enqueue(cmd1.entity_id, cmd1)   -- assuming new enqueue(entity_id, cmd)

        expect(#CommandQueue.queue).to_equal(1, "Command enqueued")
        expect(CommandQueue.queue[1][3]).to_equal("pending", "Initial status is pending")

        local entry = CommandQueue:get_next_pending()   -- or :dequeue() if you kept the name
        expect(entry).not_nil()
        expect(entry[1]).to_equal(cmd1.entity_id)
        expect(entry[2]).to_equal(cmd1)
        expect(entry[3]).to_equal("processing", "Status updated to processing")

        local success, err = CommandQueue:process_one(entry, _G.MockEngine)
        expect(success).to_be_truthy()
        expect(err).to_be_nil()

        expect(entry[3]).to_equal("done", "Status updated to done on success")
        expect(#CommandQueue.history).to_equal(1, "Logged to history")
        expect(#CommandQueue.queue).to_equal(1, "Command stays in queue (non-destructive)")
        expect(cmd1.was_executed).to_equal(true, "execute() was called")
        expect(cmd1.engine_received).to_equal(_G.MockEngine, "Correct engine passed")

        print("✓ Enqueue + process_next passed\n")
    end)

    it("Test 2: Multiple commands + process_all", function()
        local cmd2 = create_dummy_command(entity.id, "JumpActions", mock_component_name)
        local cmd3 = create_dummy_command(entity.id, "AttackActions", mock_component_name, nil, function(self)
            self.side_effect = "boom!"
        end)

        CommandQueue:enqueue(cmd2.entity_id, cmd2)
        CommandQueue:enqueue(cmd3.entity_id, cmd3)

        expect(#CommandQueue.queue).to_equal(2)

        local processed_count = CommandQueue:process_all(_G.MockEngine)

        expect(processed_count).to_equal(2, "Two commands were processed")
        -- expect(#CommandQueue.queue).to_equal(2, "Queue still contains processed commands")
        expect(#CommandQueue.history).to_equal(2, "Both logged to history")

        -- Optional: if you have cleanup after process_all
        CommandQueue:cleanup()
        expect(#CommandQueue.queue).to_equal(0, "Queue cleared after cleanup")

        expect(cmd3.side_effect).to_equal("boom!", "Custom execute logic ran")
        print("✓ Multiple commands + process_all passed\n")
    end)

    -- If you still have execute_immediately (bypass queue completely)
    it("Test 3: execute_immediately (bypass queue)", function()
        local cmd4 = create_dummy_command(entity.id, "InstantCast", mock_component_name)
        
        -- Pass entity_id + wrapper
        local success, err = CommandQueue:execute_immediately(entity.id, cmd4, _G.MockEngine)

        expect(success).to_be_truthy()
        expect(#CommandQueue.queue).to_equal(0, "Queue untouched")
        expect(#CommandQueue.history).to_equal(1, "Logged to history anyway")
        expect(cmd4.was_executed).to_equal(true)
        print("✓ Immediate execution passed\n")
    end)
    summary()
end)

describe("MoveToCommand specific tests", function()
    local entity = {}

    before_each(function()
        CommandQueue:reset()
        _G.MockEngine:Reset()
        entity = _G.MockEngine:CreateEntity("entities", "Position_Commands")
        _G.MockEngine:AddComponent(entity.id, "Position_Commands", "Position", initial_pos)
    end)

    it("Test 1: Full move via queue", function()
        local reposition_data = { from_x = 0, from_y = 0, to_x = 15, to_y = 25 }
        local cmd = MoveToCommand:new(entity.id, reposition_data)

        CommandQueue:enqueue(entity.id, cmd)

        local success = CommandQueue:process_next(_G.MockEngine)
        expect(success).to_be_truthy()

        local final_pos = _G.MockEngine:GetComponent(entity.id, "Position_Commands", "Position")
        expect(final_pos[2].x).to_equal(15)
        expect(final_pos[2].y).to_equal(25)

        local entry = CommandQueue:get_commands_for_entity(entity.id)
        expect(entry[3]).to_equal("done")
        expect(#CommandQueue.queue).to_equal(1)   -- still there
        expect(#CommandQueue.history).to_equal(1)

        local history_log = _G.MockEngine.calls.PositionCommands or {}
        expect(#history_log).to_equal(1)
        expect(history_log[1].action).to_equal("update_position")
    end)

    it("Test 3: Handles missing Position component gracefully (silent fail)", function()
        local entity_no_pos = _G.MockEngine:CreateEntity("entities", "Position_Commands")
        -- No Position component added on purpose

        local reposition_data = { to_x = 100, to_y = 200 }
        local cmd = MoveToCommand:new(entity_no_pos.id, reposition_data)

        CommandQueue:enqueue(entity_no_pos.id, cmd)

        local entry = CommandQueue:get_next_pending()
        local success, err = CommandQueue:process_next(entry, _G.MockEngine)
        CommandQueue:resolve(entity.id, success) -- Call resolve to update Fail/Done

        expect(success).to_be_falsy()           -- ← now testable thanks to pcall
        expect(err).not_nil()             -- error message captured

        expect(entry[3]).to_equal("failed")     -- ← important new assertion

        local history_log = _G.MockEngine.calls.PositionCommands or {}
        expect(#history_log).to_equal(0, "No logging when failed due to missing component")
    end)
    summary()
end)

-- Undo tests will likely need bigger changes depending on how undo is implemented now
-- (e.g. if undo removes from history or reverts status back to pending)
-- For now — minimal update assuming undo works on history:
describe("Command queue: Undo tests (preliminary)", function()
    local entity = {}
    local initial_pos = { { x = 0, y = 0 }, { x = 0, y = 0 } }

    before_each(function()
        CommandQueue:reset()
        _G.MockEngine:Reset()
        entity = _G.MockEngine:CreateEntity("entities", "Position_Commands")
        _G.MockEngine:AddComponent(entity.id, "Position_Commands", "Position", initial_pos)
    end)

    it("undo works properly (basic check)", function()
        -- Enqueue → process → undo
        local cmd = MoveToCommand:new(entity.id, { x = 15, y = -5 })
        CommandQueue:enqueue(entity.id, cmd)

        expect(#CommandQueue.queue).to_equal(1)
        expect(CommandQueue.queue[1][3]).to_equal("pending")
        expect(#CommandQueue.history).to_equal(0)

        CommandQueue:process_next(_G.MockEngine)
        expect(#CommandQueue.queue).to_equal(1)
        expect(#CommandQueue.history).to_equal(1)
        expect(CommandQueue.history[1][3]).to_equal("done")

        -- TODO: Fix logic and Tests for Undo (update logic for Resolve as well)
        CommandQueue:undo_last(_G.MockEngine)
        expect(#CommandQueue.queue).to_equal(1)
        expect(#CommandQueue.history).to_equal(1)
    end)
    summary()
end)
