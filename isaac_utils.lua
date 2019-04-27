--[[
  isaac_utils.lua

  Utility functions for manipulating objects from the Binding of Isaac: Afterbirth API
]]


-- retrieves the player userdata
function getPlayer()
  return Isaac.GetPlayer(0)
end

-- get the position of the player in-game
-- these coordinates are used for doing stuff in-game
function getPlayerPosition()
  return getPlayer().Position
end

-- get the position of the player on the screen
-- these coordinates are used for drawing to the screen
function getPlayerScreenPosition()
  return Isaac.WorldToScreen(getPlayerPosition())
end

function getScreenPosition(pos)
  return Isaac.WorldToScreen(pos)
end

function isEntityBossDying(entity)
  return isEntityFlagTrue(entity, 20)
end

-- returns if the given entity has the EntityFlag true
function isEntityFlagTrue(entity, flagNum)
  local flags = toBitBools(entity:GetEntityFlags())
  return flags[flagNum]
end

-- is any entity in this room a boss dying?
function isBossDying()
  for index, entity in pairs(getAllRoomEntities()) do
    if isEntityBossDying(entity) then
      return true
    end
  end
  return false
end

function convertListOfIndexToPos(indexList)
  local convertedList = {}
  for indexInList, nextIndex in pairs(indexList) do
    convertedList[indexInList] = getGridPos(nextIndex)
  end
  return convertedList
end

-----------------------------------------
------------ ROOMS AND DOORS ------------
-----------------------------------------

-- gets the current room index
function getCurrentRoom()
  return Game():GetLevel():GetCurrentRoomDesc().GridIndex
end

-- returns true if the current room adjacent rooms are the boss room
function isBossRoom()
  return Game():GetRoom():GetType() == RoomType.ROOM_BOSS
end

-- returns true if any adjacent rooms are the boss room
function anyUnvisitedBossRooms()
  local doors = getAllDoors()
  for _, door in pairs(doors) do
    if door.TargetRoomType == RoomType.ROOM_BOSS and not visitedRooms[getTargetRoomIndex(door)] then
      return true
    end
  end
  return false
end

function getAllDoors()
  local room = Game():GetRoom()
  doors = {}
  for _, idx in pairs(DoorSlot) do
    door = room:GetDoor(idx)
    if door then
      table.insert(doors, door)
    end
  end
  return doors
end

function isDoorUnlocked(door)
  if not door then
    return false
  else
    return not door:IsLocked()
  end
end

function isDoorSecret(door)
  if not door then
    return false
  else
    return (door.TargetRoomType == RoomType.ROOM_SECRET or door.TargetRoomType == RoomType.ROOM_SUPERSECRET) and door:CanBlowOpen()
  end
end

-- good doors are unlocked doors that lead to another normal room, the boss, or an item room
function isGoodDoor(door)
  return isDoorUnlocked(door) and not isDoorSecret(door) and
    ((door.TargetRoomType == RoomType.ROOM_DEFAULT) or
    (door.TargetRoomType == RoomType.ROOM_BOSS) or
    (door.TargetRoomType == RoomType.ROOM_TREASURE))
end



function makeDoorPair(door)
  return {door, DoorSlotEnumReverse[door.Slot]}
end

function getGoodDoors()
  return filter(isGoodDoor, getAllDoors())
end

-- returns a STABLE room index that is unique to that room (unlike `door.TargetRoomIndex`)
function getTargetRoomIndex(door)
  return Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex).GridIndex
end

-- returns whether there is an unobstructed line of movement between
-- the given two grid indices
function isDirectPath(pos1, pos2)
  return Game():GetRoom():CheckLine(getGridPos(pos1), getGridPos(pos2), 0, 0, true, true)
end

function getPlayerGridIndex()
   return getGridIndex(getPlayerPosition())
end

function getGridIndex(pos)
  return Game():GetRoom():GetClampedGridIndex(pos)
end

function getGridPos(index)
   return Game():GetRoom():GetGridPosition(index)
end

function manhattanDist(gridIndex1, gridIndex2)
  local xPos1 = modulo(gridIndex1, getRoomWidth())
  local yPos1 = math.floor(gridIndex1 / getRoomWidth())
  local xPos2 = modulo(gridIndex2, getRoomWidth())
  local yPos2 = math.floor(gridIndex2 / getRoomWidth())
  return math.abs(xPos1 - xPos2) + math.abs(yPos1 - yPos2)
end

function getRoomWidth()
  return Game():GetRoom():GetGridWidth()
end

function getRoomHeight()
  return Game():GetRoom():GetGridHeight()
end

function getAllAdjacentGridIndices(gridIndex)
  local roomWidth = getRoomWidth()
  local roomHeight = getRoomHeight()
  local nextIndices = {}
  nextIndices[1] = gridIndex - roomWidth     -- UP
  nextIndices[2] = gridIndex + roomWidth     -- DOWN
  nextIndices[3] = gridIndex - 1             -- LEFT
  nextIndices[4] = gridIndex + 1             -- RIGHT
  nextIndices[5] = gridIndex - roomWidth - 1 -- TOPLEFT
  nextIndices[6] = gridIndex - roomWidth + 1 -- TOPRIGHT
  nextIndices[7] = gridIndex + roomWidth - 1 -- BOTTOMLEFT
  nextIndices[8] = gridIndex + roomWidth + 1 -- BOTTOMRIGHT
  return nextIndices
end

function getHorizontalGridIndices(gridIndex)
  local roomWidth = getRoomWidth()
  local roomHeight = getRoomHeight()
  local nextIndices = {}
  nextIndices[1] = gridIndex - roomWidth     -- UP
  nextIndices[2] = gridIndex + roomWidth     -- DOWN
  nextIndices[3] = gridIndex - 1             -- LEFT
  nextIndices[4] = gridIndex + 1             -- RIGHT
  return nextIndices
end

function getDiagonalGridIndices(gridIndex)
  local roomWidth = getRoomWidth()
  local roomHeight = getRoomHeight()
  local nextIndices = {}
  nextIndices[1] = gridIndex - roomWidth - 1 -- TOPLEFT
  nextIndices[2] = gridIndex - roomWidth + 1 -- TOPRIGHT
  nextIndices[3] = gridIndex + roomWidth - 1 -- BOTTOMLEFT
  nextIndices[4] = gridIndex + roomWidth + 1 -- BOTTOMRIGHT
  return nextIndices
end

-- returns the first trapdoor in the room
function getTrapDoor()
  local currRoom = Game():GetRoom()
  local i = 1
  while i < Game():GetRoom():GetGridSize() do
    local gridEntity = currRoom:GetGridEntity(i)
    if gridEntity ~= nil and gridEntity:GetType() == GridEntityType.GRID_TRAPDOOR then -- if we have found a TrapDoor
      return gridEntity
    end
    i = i + 1
  end
end

-- returns the first trophy in the room
function getWinEntity()
  for _, entity in pairs(getAllRoomEntities()) do
    if entity.Type == 5 and (entity.Variant == 340 or entity.Variant == 370) then
      return entity
    end
  end
end

-- get all buttons / pressure plates in room
function getUnpressedPressurePlates()
  local currRoom = Game():GetRoom()
  local pressurePlates = {}
  local i = 1
  while i < Game():GetRoom():GetGridSize() do
    local gridEntity = currRoom:GetGridEntity(i)
    if gridEntity ~= nil and gridEntity:GetType() == GridEntityType.GRID_PRESSURE_PLATE
    and gridEntity:GetSaveState().State == 0 then
      pressurePlates = append(pressurePlates, getGridIndex(gridEntity.Position))
    end
    i = i + 1
  end
  return pressurePlates
end


-- gets all entities in the room and puts them in a table list
function getAllRoomEntities()
  local entityList = Game():GetRoom():GetEntities()

  local entityGridList = {}
  local listIndex = 1
  local i = 0
  local iterating = true
  while iterating do
    local entity = entityList:Get(i)
    entityGridList[listIndex] = entity
    listIndex = listIndex + 1
    i = i + 1
    if (i >= entityList:__len()) then
      iterating = false
    end
  end
  return entityGridList
end

-- are there no enemies in this room?
function noEnemies()

  local entityList = Game():GetRoom():GetEntities()

  local i = 0
  while true do
    local entity = entityList:Get(i)
    if (entity:IsActiveEnemy()) then return false end
    i = i + 1
    if (i >= entityList:__len()) then
      return true
    end
  end
end

-- get a list of all game entities (not GRID entities) at the given grid index
function getAllRoomEntitiesAtIndex(gridIndex)
  local entityList = Game():GetRoom():GetEntities()

  local entityGridList = {}
  local listIndex = 1
  local i = 0
  local iterating = true
  while iterating do
    local entity = entityList:Get(i)
    if (getGridIndex(entity.Position)) == gridIndex then
      entityGridList[listIndex] = entity
      listIndex = listIndex + 1
    end
    i = i + 1
    if (i >= entityList:__len()) then
      iterating = false
    end
  end
  return entityGridList
end

-- gets the door in the room that leads the specified roomIndex
function getDoorTo(roomIndex)
  local allDoors = getAllDoors()
  for _, door in pairs(allDoors) do
    if getTargetRoomIndex(door) == roomIndex then return door end
  end
  return nil
end

function getClosestFromIndices(gridIndexList)
  local closestDist = manhattanDist(getGridIndex(getPlayerPosition()), gridIndexList[1])
  local closestIndex = gridIndexList[1]
  for _, gridIndex in pairs(gridIndexList) do
    local dist = manhattanDist(getGridIndex(getPlayerPosition()), gridIndex)
    if dist < closestDist then
      closestDist = dist
      closestIndex = gridIndex
    end
  end
  return closestIndex
end

-- returns a list of rooms given a list of doors
function convertDoorsToRoomIndices(doors)
  return map(getTargetRoomIndex, doors)
end

allowedPickupTypes = {
  "BOMB", "DOUBLE_BOMB", "GOLDEN_BOMB",
  "PENNY", "NICKEL", "DIME", "DOUBLE_PENNY", "LUCKY_PENNY", "STICKY_NICKEL",
  "KEY",
  "CLOSED_CHEST",
  "BAG",
  "SOUL_HEART"
}

-- gets all entities in the room that are allowed pickups
function getAllowedPickups()
  return filter(isAllowedPickup, getAllRoomEntities())
end

-- determines if our given entity is one of the allowed pickups
function isAllowedPickup(entity)
  return contains(allowedPickupTypes, getEntitySubType(entity))
end
