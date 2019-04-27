directions = nil
goalTest = nil
currentlyNavigatingTo = "" -- this is bugged


function setNavigationTo(name, goalPosition, newGoalTest)
  
  -- if we are already navigating here, then don't do it again
  if not directions and currentlyNavigatingTo == name then return false end
  
  directions = getDirectionsTo(goalPosition)
  
  -- if we have found directions to this position, then we set our directions
  if #directions ~= 0 then
    directionIndex = 1
    goalTest = newGoalTest
    currentlyNavigatingTo = name
    setIsaacMessage(name, 100)
    return true -- return true so we can stop from navigating to other things
  end
  
  return false
end

------------------------------------------------------------------------
-- THIS IS WHERE WE CHOOSE WHERE TO GO NEXT AND UPDATE OUR DIRECTIONS --
------------------------------------------------------------------------
function navigate()
  
  -- DON'T RUN THIS CODE IF OUR MOD IS DISABLED
  if not modEnabled then return end
  
  -- obviously prioritize beating the game
  local trophy = getWinEntity()
  if (trophy) then
    
    if setNavigationTo("trophy",
      trophy.Position,
      function () return false end) then return end
  end

  -- if there are enemies in the room fight them
  if (not noEnemies()) then
    directions = nil
    -- here you want to set your movement and shoot directions
    shootDirection = nil
    moveDirectionX = nil
    moveDirectionY = nil
    return
  end

  local pressurePlates = getUnpressedPressurePlates()
  if (#pressurePlates > 0) then
    
    if setNavigationTo("Triggering pressure plate",
      getGridPos(getClosestFromIndices(pressurePlates)),
      function () return #getUnpressedPressurePlates() == #pressurePlates - 1 end) then return end
  end

  -- if there are pedestal items in the room, get those first
  local pedestalItems = getPassivePedestalItems()
  if (#pedestalItems > 0) then
    
    if setNavigationTo("Getting pedestal item",
      pedestalItems[1].Position,
      function () return #getPassivePedestalItems() == #pedestalItems - 1 end) then return end

  end

  -- if there are normal items in the room, get them next
  local pickups = getAllowedPickups()
  if (#pickups > 0) then
    
    if setNavigationTo("Getting pickup",
      pickups[1].Position,
      function () return #getAllowedPickups() == #pickups - 1 end) then return end
  end

  -- if there is a trapdoor to the next floor, go there next
  local trapDoor = getTrapDoor()
  if (trapDoor) then
    -- if trap door is closed, wait until it is open in another position
    if trapDoor:GetSaveState().State == 0 then
      
      if setNavigationTo("Waiting for trapdoor to open",
        getGridPos(getGridIndex(getTrapDoor().Position) - 1 - getRoomWidth()),
        function () return getTrapDoor():GetSaveState().State == 1 end) then return end
    end
    if trapDoor:GetSaveState().State == 1 then
      
      if setNavigationTo("Going to trapdoor",
        getTrapDoor().Position,
        function () return false end) then return end
    end
  end

  -- if we are out of things to do then advance to the next room
  -- provided that we are in a boss room... unless there is another boss room connected
  if not isBossRoom() or (isBossRoom() and anyUnvisitedBossRooms()) then
    
    if setNavigationTo("Navigating for next room",
      levelSearch().Position,
      function () return false end) then return end
  end
end


-- callback function, happens every three frames or so
function onUpdate()
  navigate()
end

-- set callback in game
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)
