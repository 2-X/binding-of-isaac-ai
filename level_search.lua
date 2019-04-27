visitedRooms = {}

function updateVisitedRooms()
  visitedRooms[getCurrentRoom()] = convertDoorsToRoomIndices(getGoodDoors())
end


function getUnvisitedDoors()
  local goodDoors = getGoodDoors()
  local unvisitedDoors = {}
  for _, door in pairs(goodDoors) do
    local roomIndex = getTargetRoomIndex(door)
    if not visitedRooms[roomIndex] then
      unvisitedDoors = append(unvisitedDoors, door)
    end
  end
  return unvisitedDoors
end

-- NAIVE IMPLEMENTATION OF LEVEL SEARCH --
-- get the next unvisited door, else backtrack
function getUnvisitedDoorOrRandom()
  -- go to the next unvisited door
  local unvisitedDoors = getUnvisitedDoors()
  if #unvisitedDoors > 0 then
    return getClosest(unvisitedDoors)
  end

  return getGoodDoors()[math.random(#getGoodDoors())]
end

-- gets closest entity to player position
function getClosest(entityList)
  local closestDist = manhattanDist(getGridIndex(getPlayerPosition()), getGridIndex(entityList[1].Position))
  local closestEntity = entityList[1]
  for _, entity in pairs(entityList) do
    local dist = manhattanDist(getGridIndex(getPlayerPosition()), getGridIndex(entity.Position))
    if dist < closestDist then
      closestDist = dist
      closestEntity = entity
    end
  end
  return closestEntity
end

-- returns the next door to go to given the current game state
function levelSearch()

  -- initialize list of nodes (rooms) we have visited and queue
  local visited = {}
  local q = Queue:new()

  local initialNode = {getCurrentRoom(), {}}
  visited[initialNode] = true
  q:push(initialNode)

  while not q:isEmpty() do
    local nextInQueue = q:pop()
    local currentRoom = nextInQueue[1]
    local pathToRoom = nextInQueue[2]

    -- if we have found a new unvisited room, then we want to get closer to it
    if (not visitedRooms[currentRoom]) then
      return getDoorTo(pathToRoom[1])
    end

    if (not visited[currentRoom]) then
      visited[currentRoom] = true
      local nextRooms = visitedRooms[currentRoom]
      if (nextRooms) then
        for _, nextRoom in pairs(nextRooms) do
          if (not visited[nextRoom]) then
            q:push({nextRoom, append(pathToRoom, nextRoom)})
          end
        end
      end
    end
  end
end
