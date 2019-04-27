--[[
  stack.lua

  This Lua class implementation of a stack data structure was based on Mário Kašuba's function
  in the book, Lua Game Development Cookbook (2015)

]]

 -- Namespace
Queue = {}
-- necessary for lua classes... apparently (http://lua-users.org/wiki/SimpleLuaClasses)
Queue.__index = Queue

function Queue.push(self, item)
	table.insert(self.list, item)
end

function Queue.pop(self)
	return table.remove(self.list, 1)
end

function Queue.isEmpty(self)
	return #self.list == 0
end

function Queue.len(self)
	return #self.list
end

function Queue.new()
	return {
		list = {},
		push = Queue.push,
		pop = Queue.pop,
		isEmpty = Queue.isEmpty,
		len = Queue.len,
	}
end

return Queue