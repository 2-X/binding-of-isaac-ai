--[[
  print_utils.lua

  Utility functions for printing debug in formation to the screen.

]]


-------------------------------
------- PRINT TO SCREEN -------
-------------------------------
local isaacMessage = ""
local isaacMessageTimer = 0
local isaacMessageTimerInitValue = 0

function printCentered(str, x, y, r, g, b, opacity)
  Isaac.RenderText(str, x - string.len(str) * 3, y, r, g, b, opacity)
end

-- sets the message to print under the player sprite for the given number of frames (duration)
function setIsaacMessage(message, duration)
  isaacMessage = message
  isaacMessageTimer = duration
  isaacMessageTimerInitValue = duration -- used to fade the text out
end

-- prints the isaacMessage under the player sprite for isaacMessageTimer frames
function printIsaacMessage()
  if isaacMessageTimer > 0 then
    local opacity = isaacMessageTimer / isaacMessageTimerInitValue
    local screenPos = getPlayerScreenPosition()
    printCentered(isaacMessage, screenPos.X, screenPos.Y, 1, 1, 1, opacity)
    isaacMessageTimer = isaacMessageTimer - 1
  end
end

function printAdjacentGridIndices()
  currentIndex = tostring(getPlayerGridIndex())

  for listIndex, gridIndex in pairs(getAllAdjacentGridIndices(getPlayerGridIndex())) do
    local gridIndexIsBlocked = isGridIndexBlocked(gridIndex)
    local gridPos = getScreenPosition(getGridPos(gridIndex))
    local r = 1
    local g = 1
    local b = 1
    if gridIndexIsBlocked then
      g = 0
      b = 0
    end
    printCentered(tostring(gridIndex), gridPos.X, gridPos.Y, r, g, b, 1)
  end
end

function printAllGridIndices(listOfDirections)
  for indexInList, nextPos in pairs(listOfDirections) do
    local screenPos = getScreenPosition(nextPos)
    Isaac.RenderText(tostring(getGridIndex(nextPos)), screenPos.X, screenPos.Y, 1, 1, 1, 1)
  end
end

function printAllGameEntities(listOfEntities)
  if listOfEntities then
    for indexInList, entity in pairs(listOfEntities) do
      local screenPos = getScreenPosition(entity.Position)
      local entityString = tostring(getEntitySubType(entity))
      printCentered(entityString, screenPos.X, screenPos.Y, 1, 1, 1, 1)
    end
  end
end

function printKeys(prefix, list, x, y)
  local listString = ""
  if prefix then listString = prefix .. ": " end
  for key, _ in pairs(list) do
    listString = listString .. tostring(key) .. ", "
  end
  Isaac.RenderText(listString, x, y, 1, 1, 1, 1)
end

function printValues(prefix, list, x, y)
  local listString = ""
  if prefix then listString = prefix .. ": " end
  for _, val in pairs(list) do
    listString = listString .. tostring(val) .. ", "
  end
  Isaac.RenderText(listString, x, y, 1, 1, 1, 1)
end

function printKeysAndValues(prefix, list, x, y)
  local listString = ""
  if prefix then listString = prefix .. ": " end
  for key, val in pairs(list) do
    listString = listString .. tostring(key) .. "=".. val .. ", "
  end
  Isaac.RenderText(listString, x, y, 1, 1, 1, 1)
end

function printVisitedRooms()
  printKeysAndValues("Visited Rooms", visitedRooms, 10, 80)
end

function printDFS()
  printVisitedRooms()
  local currentRoomString = "CurrRoom: " .. tostring(getCurrentRoom())
  Isaac.RenderText(currentRoomString, 10, 100, 1, 1, 1, 1)
end

function printGoodDoors()
  local unvisitedDoors = map(getTargetRoomIndex, getUnvisitedDoors())
  for indexInList, nextDoor in pairs(getGoodDoors()) do
    if contains(unvisitedDoors, getTargetRoomIndex(nextDoor)) then
      local screenPos = getScreenPosition(nextDoor.Position)
      printCentered("DOOR:" .. tostring(getTargetRoomIndex(nextDoor)), screenPos.X, screenPos.Y + 5, 1, 1, 1, 1)
    end
  end
end
