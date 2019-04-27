require('mobdebug').start();         -- enable debugging checkpoints
StartDebug();                        -- enable debugging
mod = RegisterMod("AI Final", 1);    -- register mod in game

-------------------------
-------- IMPORTS --------
-------------------------

-- Write str to the Isaac Console
function CPrint(str)
  Isaac.ConsoleOutput(str.."\n")
end

function import(filename)
  local _, err = pcall(require, filename)
  err = tostring(err)
  if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
    if string.match(err, "true") then
        err = "Error: require passed in config"
    end
    -- don't print this because we import files we don't want tot throw errors
    -- CPrint(err)
  end
end

-- data structures
import("data_structures.stack")
import("data_structures.queue")
import("data_structures.priority_queue")

-- utility functions
import("utils.lua_utils")
import("utils.print_utils")
import("utils.isaac_utils")
import("utils.isaac_types")
import("utils.pedestal_items")

-- callback hooks
import("callbacks.on_game_start")
import("callbacks.on_level_start")
import("callbacks.on_room_start")
import("callbacks.on_damage") -- doesn't do anything yet, might want to use this for scoring the agent
import("callbacks.on_input_request")
import("callbacks.on_step")

-- AI implementations and drivers
import("ai.agents")
import("ai.room_search")
import("ai.level_search")
import("ai.navigator")

--------------------------------
-------- PROJECT HEADER --------
--------------------------------
CPrint("----------------------------------")
CPrint("--- CS4100 Project Initialized ---")
CPrint("----------------------------------")
CPrint("")

modEnabled = true
