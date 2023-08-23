---
-- fsm_spec.lua


describe("FSM", function ()

    local FSM = require "fsm"

    describe("initialize", function ()
        it("multiple instances", function ()
            local owner1 = "a"
            local fsm1 = FSM(owner1)

            local owner2 = "b"
            local fsm2 = FSM(owner2)

            assert.are.equal(fsm1.owner, "a")
            assert.are.equal(fsm2.owner, "b")
        end)

        it("call table", function ()
            local owner = {}
            local fsm = FSM(owner)

            assert.is.Table(fsm)
        end)

        it("without owner", function ()
            assert.has_error(function () FSM() end, "FSM() try to set nil owner")
        end)
    end)

    describe("set owner", function ()
        it("valid owner", function ()
            local o = {1, 2, 3}
            local fsm = FSM({})
            fsm:set_owner(o)

            assert.are.equal(fsm.owner, o)
        end)

        it("nil owner", function ()
            local fsm = FSM({})
            assert.has_error(function () fsm:set_owner(nil) end, "FSM:set_owner() try to set nil owner")
        end)
    end)

    describe("set states", function ()

        local valid_state = {
            enter = function () end,
            execute = function () end,
            exit = function () end
        }

        local fsm = nil

        before_each(function ()
            fsm = FSM({})
        end)

        it("valid current state", function ()
            fsm:set_current_state(valid_state)

            assert.are.equal(fsm.current_state, valid_state)
        end)

        it("valid previous state", function ()
            fsm:set_previous_state(valid_state)

            assert.are.equal(fsm.previous_state, valid_state)
        end)

        it("valid global state", function ()
            fsm:set_global_state(valid_state)

            assert.are.equal(fsm.global_state, valid_state)
        end)

        it("invalid state type", function ()
            assert.has_error(
                function () fsm:set_current_state("aaa") end,
                "FSM:set_current_state() incorrect state declaration for state aaa"
            )
        end)

        it("state without all function declare", function ()
            local state = {
                enter = function () end,
                exit = function () end
            }

            assert.has_error(function () fsm:set_previous_state(state) end)
        end)

        it("state with not function fields", function ()
            local state = {
                enter = "a",
                execute = "b",
                exit = "c"
            }

            assert.has_error(function () fsm:set_global_state(state) end)
        end)

        after_each(function ()
            fsm = nil
        end)
    end)

    describe("update", function ()

        local cur_state
        local glob_state
        local fsm
        local owner

        before_each(function ()
            owner = {"a"}

            fsm = FSM(owner)
            cur_state = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }
            glob_state = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }
        end)

        it("without any state", function ()
            mock(cur_state)
            mock(glob_state)

            fsm:update()

            assert.stub(cur_state.execute).was_not.called()
            assert.stub(glob_state.execute).was_not.called()

            mock.revert(cur_state)
            mock.revert(cur_state)
        end)

        it("all states presents", function ()
            fsm:set_current_state(cur_state)
            fsm:set_global_state(glob_state)

            mock(cur_state)
            mock(glob_state)

            fsm:update()

            assert.stub(cur_state.execute).was.called(1)
            assert.stub(cur_state.execute).was_called_with(cur_state, owner)
            assert.stub(glob_state.execute).was.called(1)
            assert.stub(glob_state.execute).was_called_with(glob_state, owner)

            mock.revert(cur_state)
            mock.revert(cur_state)
        end)

        it("update with custom arguments", function ()
            fsm:set_current_state(cur_state)
            fsm:set_global_state(glob_state)

            mock(cur_state)
            mock(glob_state)

            local test_f = function () end

            fsm:update(10, "a", test_f)

            assert.stub(cur_state.execute).was.called(1)
            assert.stub(cur_state.execute).was_called_with(cur_state, owner, 10, "a", test_f)
            assert.stub(glob_state.execute).was.called(1)
            assert.stub(glob_state.execute).was_called_with(glob_state, owner, 10, "a", test_f)

            mock.revert(cur_state)
            mock.revert(cur_state)
        end)

        after_each(function ()
            fsm = nil
        end)
    end)

    describe("change state", function ()

        local fsm
        local owner
        local state_1
        local state_2

        before_each(function ()
            state_1 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            state_2 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            owner = {"a"}
            fsm = FSM(owner)
        end)

        it("new state", function ()
            fsm:set_current_state(state_1)

            fsm:change_state(state_2)

            assert.are.equal(fsm.current_state, state_2)
            assert.are.equal(fsm.previous_state, state_1)
        end)

        it("current state was nil", function ()
            assert.has_error(
                function () fsm:change_state(state_1) end,
                "FSM:change_state() current_state was nil"
            )
        end)

        it("change to nil state", function ()
            fsm:set_current_state(state_1)

            assert.has_error(
                function () fsm:change_state(nil) end,
                "FSM:change_state() trying to change to invalid state"
            )
        end)

        it("change to invalid state", function ()
            fsm:set_current_state(state_1)

            assert.has_error(
                function () fsm:change_state({enter = function () end}) end,
                "FSM:change_state() trying to change to invalid state"
            )
        end)

        after_each(function ()
            fsm = nil
        end)
    end)

    describe("revent to previous state", function ()

        local fsm
        local owner
        local state_1
        local state_2

        before_each(function ()
            state_1 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            state_2 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            owner = {"a"}
            fsm = FSM(owner)
        end)

        it("valid change", function ()
            fsm:set_current_state(state_1)
            fsm:set_previous_state(state_2)

            fsm:revent_to_previous_state()

            assert.are.equal(fsm.current_state, state_2)
            assert.are.equal(fsm.previous_state, state_1)
        end)

        it("previous state was nil", function ()
            fsm:set_current_state(state_1)

            assert.has_error(
                function () fsm:revent_to_previous_state() end,
                "FSM:change_state() trying to change to invalid state"
            )
        end)

        after_each(function ()
            fsm = nil
        end)
    end)

    describe("is in state", function ()

        local fsm
        local owner
        local state_1
        local state_2

        before_each(function ()
            state_1 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            state_2 = {
                enter = function () end,
                execute = function () end,
                exit = function () end
            }

            owner = {"a"}
            fsm = FSM(owner)
        end)

        it("positive", function ()
            fsm:set_current_state(state_1)

            assert.is.True(fsm:is_in_state(state_1))
        end)

        it("negative", function ()
            fsm:set_current_state(state_1)

            assert.is.False(fsm:is_in_state(state_2))
        end)

        it("check with not table state", function ()
            fsm:set_current_state(state_1)

            assert.is.False(fsm:is_in_state(nil))
        end)

        after_each(function ()
            fsm = nil
        end)
    end)
end)