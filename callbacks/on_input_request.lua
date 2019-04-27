------------------------------------
-------- PROGRAMMATIC INPUT --------
------------------------------------
shootDirection = nil
moveDirectionX = nil
moveDirectionY = nil

function onInputRequest(_, entity, inputHook, buttonAction)
  if modEnabled then
    if entity ~= nil then
      if inputHook == InputHook.GET_ACTION_VALUE then
        if buttonAction == moveDirectionX or buttonAction == moveDirectionY then
          return 1.0
        elseif buttonAction == shootDirection then
          return 1.0
        end
        return nil
      elseif inputHook == InputHook.IS_ACTION_PRESSED then
        if buttonAction == shootDirection then
          return true
        end
      elseif inputHook == InputHook.IS_ACTION_TRIGGERED then
        -- do something?
      end
      return nil
    end
  end
end

-- bind the MC_INPUT_ACTION callback to onInputRequest
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, onInputRequest)
