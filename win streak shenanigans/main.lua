local mod = RegisterMod('Win Streak Shenanigans', 1)
local game = Game()

-- usage: win-streak +10
-- usage: eden-tokens +10
function mod:onExecuteCmd(cmd, parameters)
  local seeds = game:GetSeeds()
  local level = game:GetLevel()
  local room = level:GetCurrentRoom()
  local max = 9999 -- 4 digits
  cmd = string.lower(cmd)
  
  if cmd == 'win-streak' then
    if not seeds:IsCustomRun() then -- not challenge or seeded run
      if string.len(parameters) >= 2 and string.sub(parameters, 1, 1) == '+' then
        local num = tonumber(string.sub(parameters, 2))
        
        if math.type(num) == 'integer' and num > 0 and num <= max then
          for i = 1, num do
            game:End(2) -- Mom / Epilogue cutscene
          end
          
          print('+' .. num)
          return
        end
      end
    end
    
    print('+0')
  elseif cmd == 'eden-tokens' then
    if not seeds:IsCustomRun() and game:GetVictoryLap() == 0 then -- not challenge, seeded run, or victory lap
      if string.len(parameters) >= 2 and string.sub(parameters, 1, 1) == '+' then
        local num = tonumber(string.sub(parameters, 2))
        
        if math.type(num) == 'integer' and num > 0 and num <= max then
          if game:IsGreedMode() then
            Isaac.ExecuteCommand('stage 7') -- ultra greed
          else
            Isaac.ExecuteCommand('stage 8') -- womb 2
          end
          
          level.LeaveDoor = DoorSlot.NO_DOOR_SLOT
          game:ChangeRoom(level:GetRooms():Get(level:GetLastBossRoomListIndex()).SafeGridIndex, -1) -- mom's heart / it lives / ultra greed / ultra greedier
          
          for i = 1, num do
            room:TriggerClear(true)
          end
          
          -- 3 = Mom's Heart / 9 = Greed / 12 = Greedier
          game:End(2)
          
          print('+' .. num)
          return
        end
      end
    end
    
    print('+0')
  end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCmd)

----------------------
-- start repentogon --
----------------------
if REPENTOGON then
  -- imgui
  ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
  ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItem', ImGuiElement.MenuItem, '\u{f528} Win Streak Shenanigans (+Eden Tokens)')
  ImGui.CreateWindow('shenanigansWindow', 'Win Streak Shenanigans (+Eden Tokens)')
  ImGui.LinkWindowToElement('shenanigansWindow', 'shenanigansMenuItem')
  
  ImGui.AddTabBar('shenanigansWindow', 'shenanigansTabBar')
  ImGui.AddTab('shenanigansTabBar', 'shenanigansTabWinStreak', 'Win Streak')
  ImGui.AddTab('shenanigansTabBar', 'shenanigansTabEdenTokens', 'Eden Tokens')
  
  ImGui.AddText('shenanigansTabWinStreak', 'Win Streak:', false, 'shenanigansTxt1')
  ImGui.AddInputInteger('shenanigansTabWinStreak', 'shenanigansWinStreak', 'Edit', nil, 0, 1, 100) -- callback doesn't work here :(
  ImGui.AddCallback('shenanigansWinStreak', ImGuiCallback.Render, function(num)
    local gameData = Isaac.GetPersistentGameData()
    local streakCounter = gameData:GetEventCounter(EventCounter.STREAK_COUNTER)
    if streakCounter == 0 then
      streakCounter = gameData:GetEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER) * -1
    end
    ImGui.UpdateData('shenanigansWinStreak', ImGuiData.Value, streakCounter)
  end)
  ImGui.AddCallback('shenanigansWinStreak', ImGuiCallback.Edited, function(num)
    local gameData = Isaac.GetPersistentGameData()
    if num > 0 then
      gameData:IncreaseEventCounter(EventCounter.STREAK_COUNTER, num - gameData:GetEventCounter(EventCounter.STREAK_COUNTER))
      gameData:IncreaseEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER, gameData:GetEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER) * -1)
    elseif num < 0 then
      gameData:IncreaseEventCounter(EventCounter.STREAK_COUNTER, gameData:GetEventCounter(EventCounter.STREAK_COUNTER) * -1)
      gameData:IncreaseEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER, math.abs(num) - gameData:GetEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER))
    else -- equals 0
      gameData:IncreaseEventCounter(EventCounter.STREAK_COUNTER, gameData:GetEventCounter(EventCounter.STREAK_COUNTER) * -1)
      gameData:IncreaseEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER, gameData:GetEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER) * -1)
    end
  end)
  
  ImGui.AddText('shenanigansTabWinStreak', 'Best Win Streak:', false, 'shenanigansTxt2')
  ImGui.AddInputInteger('shenanigansTabWinStreak', 'shenanigansBestWinStreak', 'Edit', nil, 0, 1, 100)
  ImGui.AddCallback('shenanigansBestWinStreak', ImGuiCallback.Render, function(num)
    local gameData = Isaac.GetPersistentGameData()
    ImGui.UpdateData('shenanigansBestWinStreak', ImGuiData.Value, gameData:GetEventCounter(EventCounter.BEST_STREAK))
  end)
  ImGui.AddCallback('shenanigansBestWinStreak', ImGuiCallback.Edited, function(num)
    local gameData = Isaac.GetPersistentGameData()
    gameData:IncreaseEventCounter(EventCounter.BEST_STREAK, num - gameData:GetEventCounter(EventCounter.BEST_STREAK))
  end)
  
  ImGui.AddText('shenanigansTabEdenTokens', 'Eden Tokens:', false, 'shenanigansTxt3')
  ImGui.AddInputInteger('shenanigansTabEdenTokens', 'shenanigansEdenTokens', 'Edit', nil, 0, 1, 100)
  ImGui.AddCallback('shenanigansEdenTokens', ImGuiCallback.Render, function(num)
    local gameData = Isaac.GetPersistentGameData()
    ImGui.UpdateData('shenanigansEdenTokens', ImGuiData.Value, gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
  end)
  ImGui.AddCallback('shenanigansEdenTokens', ImGuiCallback.Edited, function(num)
    local gameData = Isaac.GetPersistentGameData()
    gameData:IncreaseEventCounter(EventCounter.EDEN_TOKENS, num - gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
  end)
  
  -- console
  Console.RegisterCommand('win-streak', 'Increment your win streak (win-streak +1)', 'Increment your win streak (win-streak +1)', false, AutocompleteType.NONE)
  Console.RegisterCommand('eden-tokens', 'Increment your eden tokens (eden-tokens +1)', 'Increment your eden tokens (eden-tokens +1)', false, AutocompleteType.NONE)
end
--------------------
-- end repentogon --
--------------------