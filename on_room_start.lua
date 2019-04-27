-- called whenever you enter a room
function onRoomStart()
  pointAndClickPos = nil
  directions = nil
  goalTest = nil
  currentlyNavigatingTo = ""
  directionIndex = 1
  updateVisitedRooms()
end

-- bind the MC_POST_NEW_ROOM callback
-- this event is triggered every time you enter a room
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomStart)
