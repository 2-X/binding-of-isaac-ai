function aStarRoomSearch(index1, index2)
  local goalIndex = index2 -- our goal is to get from pos1 to pos2
  local openNodes = {}
  local closedNodes = {}
  local g = {}
  local pq  = PriorityQueue:new()

  local initialNode = {index1, {}} -- a tuple of value and path
  pq:put(initialNode, 0)
  g[index1] = 0

  while (not pq:empty()) do
    local topOfQueue = pq:pop()
    local currentIndex = topOfQueue[1]
    local pathToIndex = topOfQueue[2]
    -- goal test
    if (currentIndex == goalIndex) then
      return pathToIndex
    end
    if (not closedNodes[currentIndex] == true) then
      closedNodes[currentIndex] = true
      for _, nextIndexCostPair in pairs(nextValidGridIndices(currentIndex, goalIndex)) do
        local nextIndex = nextIndexCostPair[1]
        local cost = nextIndexCostPair[2]
        costToNextIndex = g[currentIndex] + cost + manhattanDist(nextIndex, goalIndex)
        if (not closedNodes[nextIndex] == true) then
          if (not openNodes[nextIndex] == true) then
             openNodes[nextIndex] = true
             pq:put({nextIndex, append(pathToIndex, nextIndex)}, costToNextIndex)
             g[nextIndex] = g[currentIndex] + cost
          end
        else
          if (costToNextIndex < g[nextIndex]) then
            pq:update({nextIndex, append(pathToIndex, nextIndex)}, costToNextIndex) -- update, not put
            g[nextIndex] = g[currentIndex] + cost
            openNodes[nextIndex] = false
          end
        end
      end
    end
  end
  -- if there is no path between them, then return an empty set of directions
  return {}
end


function aStarToPos(pos)
  return aStarRoomSearch(getGridIndex(getPlayerPosition()), getGridIndex(pos))
end


-- returns a list of Vector indicating the directions to get to the given pos
function getDirectionsTo(pos)
  return convertListOfIndexToPos(aStarToPos(pos))
end


-- successor function for room search, returns the next valid indices
-- the next valid indices are the horizontals and diagonals that isaac can move to
function nextValidGridIndices(gridIndex, goalIndex)
  local nextIndices = {}

  -- HORIZONTALS: UP, DOWN, LEFT, RIGHT
  local horizontalIndices = getHorizontalGridIndices(gridIndex)

  -- DIAGONALS: TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT
  local diagonalIndices = getDiagonalGridIndices(gridIndex)

  nextIndices = nextValidGridIndicesHelper(horizontalIndices, gridIndex, goalIndex, false, nextIndices)
  nextIndices = nextValidGridIndicesHelper(diagonalIndices, gridIndex, goalIndex, true, nextIndices)

  return nextIndices
end


-- helper for successor function
function nextValidGridIndicesHelper(adjacentIndices, gridIndex, goalIndex, isDiagonal, acc)
  local nextIndices = acc
  for _, successorIndex in pairs(adjacentIndices) do
    if not isGridIndexBlocked(successorIndex)
    and (not isDiagonal or isDirectPath(gridIndex, successorIndex))
    or (manhattanDist(gridIndex, goalIndex) == 1 and successorIndex == goalIndex) then
        local succEntity = Game():GetRoom():GetGridEntity(successorIndex)
        local succCost = 1

        -- modifiy successor cost
        if succEntity then
          if succEntity:GetType() == GridEntityType.GRID_SPIDERWEB then
            succCost = 2
          end
          if succEntity:GetType() == GridEntityType.GRID_POOP then
            succCost = 5
          end
        end
        if isDiagonal then succCost = succCost * 1.5 end
        nextIndices = append(nextIndices, {successorIndex, succCost})
      end
    end
  return nextIndices
end


-- verify how this works with all entities
function isGridIndexBlocked(gridIndex)
  -- restrict out of bounds indices
  if (gridIndex > Game():GetRoom():GetGridSize() or gridIndex < 0) then return true end

  local gridEntity = Game():GetRoom():GetGridEntity(gridIndex)
  if (gridEntity ~= nil) then
    local t = gridEntity:GetType()
    return not (t == nil
      or t == 0
      or t == GridEntityType.GRID_DECORATION
      or t == GridEntityType.GRID_SPIKES_ONOFF
      or t == GridEntityType.GRID_SPIDERWEB
      or t == GridEntityType.GRID_PRESSURE_PLATE
      or t == GridEntityType.GRID_POOP -- since we are shooting in the direction we move, we will destroy it
      or t == GridEntityType.GRID_ROCK and gridEntity:GetSaveState().State == 2 -- if it is destroyed
      or t == GridEntityType.GRID_TNT and gridEntity:GetSaveState().State == 4 -- if it is destroyed
      )
  else
    -- check if there are any blocking entities in our way
    local blockingEntities = filter(entityBlocksMovement, getAllRoomEntities())
    for _, entity in pairs(blockingEntities) do
      if getGridIndex(entity.Position) == gridIndex then
        return true
      end
    end
    return false
  end
end


-- returns whether an entity blocks your movement or not
-- should avoid these ones in the roomSearch problem
function entityBlocksMovement(entity)
  return (entity.Type == 5 and entity.Variant == 100) -- pedestal items
  or (entity.Type == 6) -- slot machines and bums
end
