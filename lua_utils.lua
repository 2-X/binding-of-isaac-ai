--[[
  lua_utils.lua

  Utility functions for general Lua data manipulation.
]]

----------------------------------
------------ GENERAL -------------
----------------------------------

-- Compares equality of arbitrarily nested tables
function equal(expected, actual)
  if type(expected) ~= type(actual) then
    return false
  end

  if type(expected) == "table" then
    for index, val in pairs(expected) do
      if not equal(val, actual[index]) then
        return false
      end
    end
    return true
  end

  return expected == actual
end


------------------------------------
-------------   MATH   -------------
------------------------------------

function modulo(a, b)
  return (a - math.floor(a/b)*b)
end


-----------------------------------
-------- TYPE CONVERSIONS ---------
-----------------------------------

-- TODO add support for other types
function num(value)
  local value_type = type(value)
  if value_type == "boolean" then
    return value and 1 or 0
  end
  return nil
end



-----------------------------------
------------- ARRAYS --------------
-----------------------------------

-- swaps key and value pairs
function makeReverseTable(someTable)
  local newTable = {}
  for index, val in pairs(someTable) do
    newTable[val] = index
  end
  return newTable
end

-- swaps key and value pairs
function string_append(someTable, delimiter)
  local str = ""
  for index, val in pairs(someTable) do
    str = str .. tostring(val) .. delimiter
  end
  return str
end

-- reverses the order of an array
function reverse(arr)
	local i, j = 1, #arr

	while i < j do
		arr[i], arr[j] = arr[j], arr[i]

		i = i + 1
		j = j - 1
	end
end

-- Check membership of val in list
function contains(list, val)
    for index, value in ipairs(list) do
        if equal(value, val) then
            return true
        end
    end

    return false
end

-- Basic functional mapping
function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

-- Basic functional mapping
function filter(filter_func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    if filter_func(v) then
      table.insert(new_array, v)
    end
  end
  return new_array
end

-- return a new array equal to old plus one new element elt
function append(array, elt)
  local newArr = {}
  for k, v in ipairs(array) do
    newArr[k] = v
  end
  newArr[#array+1] = elt
  return newArr
end

-- return a new array equal to old plus one new element 'elt' inserted at 'index'
function appendAtIndex(array, elt, index)
  local newArr = {}
  for k, v in ipairs(array) do
    if k < index then
      newArr[k] = v
    elseif k == index then
      newArr[k] = elt
      newArr[k+1] = v
    else
      newArr[k+1] = v
    end
  end
  return newArr
end

--------------------------------------
-------- BINARY MANIPULATION ---------
--------------------------------------

-- converts a decimal number to a list of booleans representing the binary conversion, least significant first.
function toBitBools(num)
    local t={} -- will contain the bits
    local i=1
    while num>0 do
        rest=math.fmod(num,2)
        t[i]=(rest == 1)
        i = i + 1
        num=(num-rest)/2
    end
    return t
end
