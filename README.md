# finita

Finite State Machine implementation for Lua. Based on Mat Buckland's Game AI by Example

[![Build Status](https://travis-ci.org/NickFlexer/finita.svg?branch=master)](https://travis-ci.org/NickFlexer/finita) [![Coverage Status](https://coveralls.io/repos/github/NickFlexer/finita/badge.svg?branch=master)](https://coveralls.io/github/NickFlexer/finita?branch=master)

## Usage

Put ```fsm.lua``` inside your project and require it:

```lua
local FSM = require "fsm"
```

Finita uses the state class. Each state can be declared in separate file like this:

```lua
local MyMegaState = {}

function MyMegaState:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

-- this method execute when the state is entered
function MyMegaState:enter(owner)
  -- do staff...
end

-- this is called by the FSM's update function each update step
function MyMegaState:execute(owner, ...)
  -- do staff...
end

-- this will execute when the state is exited
function MyMegaState:exit(owner)
  -- do staff...
end

return MyMegaState
```

Finita automatically checks that the ```state``` implements required methods. If state failed verification, FSM raise ```incorrect state declaration``` error

## Example

```lua
local FSM = require "fsm"

local MenuState = require "menu_state"
local GameplayState = require "game_state"


local Game = {}

function Game:new()
  -- create instance of FSM class and pass Game as FSM owner
  self.fsm = FSM(self)

  -- owner stores links to all states
  self.states = {
	menu = MenuState:new(),
	gameplay = GameplayState:new()
  }

  -- set current state
  self.fsm:set_current_state(self.states.menu)

  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Game:update(dt)
  -- update fsm and pass extra paremeter 'dt' to current_state execute method
  self.fsm:update(dt)
end

function Game:handle_input(key)
  if key == "Enter" then
    -- change current state
    self.fsm:change_state(self.states.gameplay)
  end
end

return Game
```

## Documentation

**```FSM(owner)```**

create new FSM object:

```lua
local  fsm = FSM(owner)
```

or

```lua
local  fsm = FSM:new(owner)
```

---

**```:set_owner(owner)```**

passed owner of FSM. If owner is ```nil``` method raise ```try to set nil owner``` error

---

Methods for initialize FSM:

**```:set_current_state(state)```**

**```:set_previous_state(state)```**

**```:set_global_state(state)```**

```set_current_state()``` and ```set_global_state()``` calls ```enter``` methods of passed state.

---

**```:update(...)```**
call this method to update FSM. You can pass variable numbers of arguments to ```update```. Method executes the following sequence:
* if global state exist, call its ```execute``` method
* same  for the current state
---

**```:change_state(new_state)```**
method executes the following sequence:
* call the ```exit``` method of the existing state
* change current state to the new state
* call the ```enter``` method of the new state

This method can raise two errors:
* ```current_state was nil``` if current sate not passed in FSM
* ```trying to change to invalid state``` if new state failed verification

---

**```:revent_to_previous_state()```**

change state back to the previous state

---

**```:is_in_state(state)```**

returns ```true``` if the current state is equal to the state passed as a parameter

## Testing

Tests defined with [busted](http://olivinelabs.com/busted/) test farmework. To run the suite, install busted and simply execute ```busted``` in the module directory.
