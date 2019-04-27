---------------------------------
-------- FREQUENT CHECKS --------
---------------------------------

-- code to be run every frame
function onStep()
  -- enable and disable the AI mod by pressing 'R' on your keyboard
  if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, 0) then
    if modEnabled then
      modEnabled = false
      Isaac.ConsoleOutput("AI Mod Disabled\n")
      setIsaacMessage("AI Disabled (" .. agentTypeString .. ")", 100)
    else
      modEnabled = true
      timer = 0
      Isaac.ConsoleOutput("AI Mod Enabled\n")
      setIsaacMessage("AI Enabled (" .. agentTypeString .. ")", 100)
    end
  end

  -- print the isaacMessage
  printIsaacMessage()

  if modEnabled then
    -- this agent moves left and then right every moveLeftAndRightEvery tics
    if agentType == AgentType.MoveLeftAndRight then
      MoveLeftAndRightAgent()
    end

    -- this agent moves and shoots in the last move / shoot direction
    if agentType == AgentType.Snake then
      SnakeAgent()
    end

    -- this agent moves directly to the point on the screen that you click!
    if agentType == AgentType.PointAndClick then
      PointAndClickAgent()
    end

    if agentType == AgentType.SmartBoi then
      SmartBoiAgent()
    end
  -- printAdjacentGridIndices()
  -- printAllGameEntities(getAllRoomEntities())
  -- if directions then printAllGridIndices(directions) end
end
printAllGameEntities(getAllRoomEntities())
--printDFS()
printGoodDoors()
end

-- bind the MC_POST_RENDER callback to onRender
-- this event is triggered every frame, which is why we are using it to modify the input and render
mod:AddCallback(ModCallbacks.MC_POST_RENDER, onStep)
