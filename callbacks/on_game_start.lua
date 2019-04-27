--------------------------------
-------- DEBUG COMMANDS --------
--------------------------------
-- Define debug variables
local makeIsaacInvincible = true
local killAllEnemiesOnRoomStart = true

function onGameStart()
  CPrint("### New Game Started ###")

  -- Isaac takes damage but his health never decreases
  if makeIsaacInvincible then
    Isaac.ExecuteCommand("debug 3")
  end

  -- Make all enemies in room die when entering the room
  if killAllEnemiesOnRoomStart then
    Isaac.ExecuteCommand("debug 10")
  end

  -- print variables to console
  CPrint(string.format("makeIsaacInvincible = %s", tostring(makeIsaacInvincible)))
  CPrint(string.format("killAllEnemiesOnRoomStart = %s", tostring(killAllEnemiesOnRoomStart)))
end

-- bind the MC_POST_GAME_STARTED callback to onGameStarted
-- this event is called when a new game is started or a game is loaded from a save state
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)
