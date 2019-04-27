--[[
  agents.lua

  Functions detailing agents that play The Binding of Isaac
]]

timer = 0
moveLeftAndRightEvery = 100

AgentType = { MoveLeftAndRight = 1, Snake = 2, PointAndClick = 3, SmartBoi = 4 }
agentType = AgentType.SmartBoi
agentTypeString = makeReverseTable(AgentType)[agentType]

pointAndClickPos = nil
pointAndClickThreshold = 20

-- this agent follows directions, this is the main AI driver
function SmartBoiAgent()

  -- our agent should never give up on the goal if we are forcing it there
  local movementThreshold = pointAndClickThreshold
  if directions and directionIndex == #directions then
    movementThreshold = 5
  end

  if directions and directions[directionIndex] then

    shootDirection = nil
    moveDirectionX = nil
    moveDirectionY = nil

    local playerPos =  getPlayerPosition()

    local xDistToNextPos = directions[directionIndex].X - playerPos.X
    local yDistToNextPos = directions[directionIndex].Y - playerPos.Y

    if math.abs(xDistToNextPos) > movementThreshold then
      if xDistToNextPos > 0 then
        moveDirectionX = ButtonAction.ACTION_RIGHT
        shootDirection = ButtonAction.ACTION_SHOOTRIGHT

      elseif xDistToNextPos < 0 then
        moveDirectionX = ButtonAction.ACTION_LEFT
        shootDirection = ButtonAction.ACTION_SHOOTLEFT
      end
    end

    if math.abs(yDistToNextPos) > movementThreshold then
      if yDistToNextPos < 0 then
        moveDirectionY = ButtonAction.ACTION_UP
        shootDirection = ButtonAction.ACTION_SHOOTUP

      elseif yDistToNextPos > 0 then
        moveDirectionY = ButtonAction.ACTION_DOWN
        shootDirection = ButtonAction.ACTION_SHOOTDOWN
      end
    else
      -- thing
    end

    if directionIndex < #directions then
      if math.abs(xDistToNextPos) <= movementThreshold and math.abs(yDistToNextPos) <= movementThreshold then
        directionIndex = directionIndex + 1
      end
    elseif goalTest() then
      directionIndex = directionIndex + 1
      directions = nil
      goalTest = nil
      currentlyNavigatingTo = ""
    end
  end
end

-- this agent just moves left and right, used for testing the `on_input_request.lua` hooks
function MoveLeftAndRightAgent()
  if timer % moveLeftAndRightEvery == 0 then
    if moveDirectionX == ButtonAction.ACTION_LEFT then
      moveDirectionX = ButtonAction.ACTION_RIGHT
    else
      moveDirectionX = ButtonAction.ACTION_LEFT
    end
    timer = 0
  end
  timer = timer + 1
end

-- this agent continously moves in the last direction you pressed and shoots behind him
function SnakeAgent()
  if Input.IsActionTriggered(ButtonAction.ACTION_LEFT, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, 0) then
    moveDirectionX = ButtonAction.ACTION_LEFT
    moveDirectionY = nil
    shootDirection = ButtonAction.ACTION_SHOOTRIGHT
  elseif Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, 0) then
    moveDirectionX = ButtonAction.ACTION_RIGHT
    moveDirectionY = nil
    shootDirection = ButtonAction.ACTION_SHOOTLEFT
  elseif Input.IsActionTriggered(ButtonAction.ACTION_UP, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, 0) then
    moveDirectionX = nil
    moveDirectionY = ButtonAction.ACTION_UP
    shootDirection = ButtonAction.ACTION_SHOOTDOWN
  elseif Input.IsActionTriggered(ButtonAction.ACTION_DOWN, 0) or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, 0) then
    moveDirectionX = nil
    moveDirectionY = ButtonAction.ACTION_DOWN
    shootDirection = ButtonAction.ACTION_SHOOTUP
  end
end

function PointAndClickAgent()
  shootDirection = nil
  moveDirectionX = nil
  moveDirectionY = nil

  if Input.IsMouseBtnPressed(0) then
    pointAndClickPos = Input.GetMousePosition(true)
    directions = getDirectionsTo(pointAndClickPos)
    directionIndex = 1
  end
  if pointAndClickPos ~= nil and directions and directionIndex <= #directions then
    local mousePosScreen = Isaac.WorldToScreen(pointAndClickPos)
    Isaac.RenderText("X", mousePosScreen.X - 3, mousePosScreen.Y - 6, 1, 0, 0, 1)

    -- print all of the grid indexes at their positions
    local playerPos =  getPlayerPosition()

    local xDistToNextPos = directions[directionIndex].X - playerPos.X
    local yDistToNextPos = directions[directionIndex].Y - playerPos.Y

    if math.abs(xDistToNextPos) > pointAndClickThreshold then
      if xDistToNextPos > 0 then
        moveDirectionX = ButtonAction.ACTION_RIGHT

      elseif xDistToNextPos < 0 then
        moveDirectionX = ButtonAction.ACTION_LEFT
      end
    end

    if math.abs(yDistToNextPos) > pointAndClickThreshold then
      if yDistToNextPos < 0 then
        moveDirectionY = ButtonAction.ACTION_UP

      elseif yDistToNextPos > 0 then
        moveDirectionY = ButtonAction.ACTION_DOWN
      end
    end

    -- move on to next position if we reach this one, unless we are forcing to move to the goal
    if math.abs(xDistToNextPos) <= pointAndClickThreshold and
    math.abs(yDistToNextPos) <= pointAndClickThreshold then
      directionIndex = directionIndex + 1
    end
  end
end
