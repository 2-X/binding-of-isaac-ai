
function onLevelStart()
  visitedRooms = {}
  updateVisitedRooms()
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onLevelStart)
