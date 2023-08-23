---
-- fsm.lua


local FSM = {}

FSM.__index = FSM

local function check_state(state)
    if type(state) == "table" then
        if state.enter and type(state.enter) == "function"
            and state.execute and type(state.execute) == "function"
            and state.exit and type(state.exit) == "function" then

            return true
        end
    end

    return false
end

local function new(owner)
    if not owner then
        error("FSM() try to set nil owner")
    end

    return setmetatable(
        {
            owner = owner,
            current_state = nil,
            previous_state = nil,
            global_state = nil
        },
        FSM
    )
end

function FSM:set_owner(owner)
    if owner then
        self.owner = owner
    else
        error("FSM:set_owner() try to set nil owner")
    end
end

function FSM:set_current_state(state)
    if check_state(state) then
        self.current_state = state
        self.current_state:enter(self.owner)
    else
        error("FSM:set_current_state() incorrect state declaration for state " .. tostring(state))
    end
end

function FSM:set_previous_state(state)
    if check_state(state) then
        self.previous_state = state
    else
        error("FSM:set_previous_state() incorrect state declaration for state " .. tostring(state))
    end
end

function FSM:set_global_state(state)
    if check_state(state) then
        self.global_state = state
        self.global_state:enter(self.owner)
    else
        error("FSM:set_global_state() incorrect state declaration for state " .. tostring(state))
    end
end

function FSM:update(...)
    if self.global_state then
        self.global_state:execute(self.owner, ...)
    end

    if self.current_state then
        self.current_state:execute(self.owner, ...)
    end
end

function FSM:change_state(new_state)
    if check_state(new_state) then
        if self.current_state then
            self.previous_state = self.current_state
            self.current_state:exit(self.owner)

            self.current_state = new_state
            self.current_state:enter(self.owner)
        else
            error("FSM:change_state() current_state was nil")
        end
    else
        error("FSM:change_state() trying to change to invalid state")
    end
end

function FSM:revent_to_previous_state()
    self:change_state(self.previous_state)
end

function FSM:is_in_state(state)
    return self.current_state == state
end

function FSM:get_current_state()
    return self.current_state
end

return setmetatable(
    {
        new = new,
        _DESCRIPTION = "Finite State Machine implementation for Lua",
        _VERSION = "v1.1"
    },
    {
        __call = function(_, ...) return new(...) end
    }
)
