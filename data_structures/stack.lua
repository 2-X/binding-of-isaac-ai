--[[
  stack.lua

  This Lua class implementation of a stack data structure was based on Mário Kašuba's function
  in the book, Lua Game Development Cookbook (2015)

]]

 -- Namespace
Stack = {}
-- necessary for lua classes... apparently (http://lua-users.org/wiki/SimpleLuaClasses)
Stack.__index = Stack

function Stack:new(list)
  obj = {}
  setmetatable(obj, Stack) -- make the obj a Stack
  obj.stack = list or {}   -- create internal stack if user does not provide one
  return obj
end

function Stack:push(item)
  -- put an item on the stack
  self.stack[#self.stack+1] = item
end

function Stack:pop()
  -- make sure there's something to pop off the stack
  if #self.stack > 0 then
    -- remove item (pop) from stack and return item
    return table.remove(self.stack, #self.stack)
  end
end

function Stack:iterator()
  -- wrap the pop method in a function
  return function()
    -- call pop to iterate through all items on a stack
    return self:pop()
  end
end

-- return whether the stack is empty or not
function Stack:isEmpty()
  return self.stack[1] == nil
end

-- look at the top element without removing it
function Stack:peek()
  return self.stack[#self.stack]
end

--------------------------------
------------ TESTS -------------
--------------------------------

function stackTest()
  stack = Stack:new({1})
  CPrint(equal(1, stack:pop()))
  CPrint(equal(nil, stack:pop()))

  stack:push(2)
  stack:push(3)
  CPrint(equal(3, stack:pop()))
  CPrint(equal(2, stack:pop()))
  CPrint(equal(nil, stack:pop()))
end

--stackTest()
