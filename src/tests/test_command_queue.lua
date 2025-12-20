-- tests/test_command_queue.lua

local init = require("../src/tests/test_init")
init.init(_G.EngineModules.COMMAND)

local CommandQueue = require("commands.command_queue")
local MoveToCommand = require("commands.move_to_command")

-- Helper: Dummy command factory for generic queue tests
local function create_dummy_command(type_name, payload, custom_execute)
    type_name = type_name or "DummyCommand"
    payload = payload or {}

    local BaseCommand = require("commands.base_command")
    local cmd = BaseCommand.new(type_name, -1, payload)

    cmd.was_executed = false
    cmd.engine_received = nil

    function cmd:execute(engine)
        self.was_executed = true
        self.engine_received = engine
        if custom_execute then
            custom_execute(self, engine)
        end
        BaseCommand.execute(self, engine)
    end

    return cmd
end

describe("Generid command Queue Tests", function()
    it ("Test 1: Enqueue + process_next", function()
        CommandQueue:clear()  -- Ensure clean state
        local cmd1 = create_dummy_command("LoginAction", { user = "player1" })

        CommandQueue:enqueue(cmd1)
        assert(#CommandQueue.queue == 1, "Command enqueued")
        assert(#CommandQueue.history == 0, "History empty before processing")

        local processed_cmd = CommandQueue:process_next(MockEngine)

        assert(processed_cmd == cmd1, "process_next returns the processed command")
        assert(#CommandQueue.queue == 0, "Queue empty after process_next")
        assert(#CommandQueue.history == 1, "Command logged in history")
        assert(cmd1.was_executed == true, "execute() was called")
        assert(cmd1.engine_received == MockEngine, "Correct engine passed")

        print("✓ Enqueue + process_next passed\n")
    end)

    it ("Test 2: Multiple commands + process_all", function()
        local cmd2 = create_dummy_command("JumpAction")
        local cmd3 = create_dummy_command("AttackAction", nil, function(self)
            self.side_effect = "boom!"
        end)

        CommandQueue:enqueue(cmd2)
        CommandQueue:enqueue(cmd3)
        assert(#CommandQueue.queue == 2)

        CommandQueue:process_all(MockEngine)

        assert(#CommandQueue.queue == 0, "Queue cleared by process_all")
        assert(#CommandQueue.history == 3, "Both new commands logged")
        assert(cmd3.side_effect == "boom!", "Custom execute logic ran")

        print("✓ Multiple commands + process_all passed\n")
    end)

    it("Test 3: execute_immediately (bypass queue)", function()
        local cmd4 = create_dummy_command("InstantCast")
        CommandQueue:execute_immediately(cmd4, MockEngine)

        assert(#CommandQueue.queue == 0, "execute_immediately doesn't touch queue")
        assert(#CommandQueue.history == 4, "Still logs to history")
        assert(cmd4.was_executed == true)

        print("✓ execute_immediately passed\n")
    end)

    it("Test 4: History querying", function()
        local attack_cmds = CommandQueue:get_history_by_type("AttackAction")
        assert(#attack_cmds == 1, "History filter works")
    end)
end)

describe("MoveToCommmand specific tests:", function()
    local entity = {}
    local initial_pos = { x = 0, y = 0 }
    local table_name = "entities"
    local component_name = "Position"
    local command_type_identifier = "Position_Commands"

    before_each(function()
        CommandQueue:clear()
        MockEngine:Reset()  -- ← This clears tables, calls, next_id → fresh start
        entity = MockEngine:CreateEntity("entities", "Position_Commands")
        MockEngine:AddComponent(entity.id, "Position_Commands", "Position", { x = 0, y = 0 })
    end)

    it("Test 1: Full move via queue", function()
        MockEngine:AddComponent(entity.id, command_type_identifier, component_name, initial_pos)

        local reposition_data = { from_x = 0, from_y = 0, to_x = 15, to_y = 25 }
        local cmd = MoveToCommand.new(entity.id, reposition_data)

        CommandQueue:enqueue(cmd)
        CommandQueue:process_next(MockEngine)

        local final_pos = MockEngine:GetComponent(entity.id, command_type_identifier, component_name)
        assert(cmd.params.initial_pos.x == 0 and cmd.params.initial_pos.y == 0, "'from' captured correctly")
        assert(cmd.params.target_pos.x == 15 and cmd.params.target_pos.y == 25, "target computed correctly")

        -- (Optional) Assert the HISTORY was logged correctly
        local history_log = MockEngine.calls.Position_Commands
        assert(#history_log == 1, "One command was logged")
        assert(history_log[1].action == "update_position", "Correct action was logged")
    end)

    it("Test 2: Partial move via TestQueue:", function()
        MockEngine:AddComponent(entity.id, command_type_identifier, component_name, initial_pos)

        local reposition_data = { to_y = 25 }
        local cmd = MoveToCommand.new(entity.id, reposition_data)

        CommandQueue:enqueue(cmd)
        CommandQueue:process_next(MockEngine)

        local final_pos = MockEngine:GetComponent(entity.id, command_type_identifier, component_name)
        assert(final_pos.x == 0 and final_pos.y == 25, "Partial move applied")
        assert(cmd.params.initial_pos.x == 0 and cmd.params.initial_pos.y == 0, "'from' captured correctly")
        assert(cmd.params.target_pos.x == 0 and cmd.params.target_pos.y == 25, "target computed correctly")

        -- (Optional) Assert the HISTORY was logged correctly
        local history_log = MockEngine.calls.Position_Commands
        assert(#history_log == 1, "One command was logged")
        assert(history_log[1].action == "update_position", "Correct action was logged")
    end)
    it("Test 3: Handles missing Position component gracefully (silent fail)", function()
        -- Create a valid entity, but deliberately do NOT add a Position component
        local entity_no_pos = MockEngine:CreateEntity("entities", "Position_Commands")

        -- Note: We skip MockEngine:AddComponent(..., "Position", ...)
        local reposition_data = { to_x = 100, to_y = 200 }  -- full or partial, doesn't matter
        local cmd = MoveToCommand.new(entity_no_pos.id, reposition_data)

        CommandQueue:enqueue(cmd)

        expect(function() CommandQueue:process_next(MockEngine) end).to_not_throw()

        -- Verify nothing was changed/logged for Position_Commands
        local history_log = MockEngine.calls.Position_Commands or {}
        assert(#history_log == 0, "No logging when Position component is missing")

        -- Optional: If you add failure logging to CommandQueue later, you could assert that
        -- print("✓ Silent fail handled gracefully\n")
    end)
end)
