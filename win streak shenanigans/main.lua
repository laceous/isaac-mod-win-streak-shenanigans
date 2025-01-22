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
    if mod:isInGame() and not seeds:IsCustomRun() then -- not challenge or seeded run
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
    if mod:isInGame() and not seeds:IsCustomRun() and game:GetVictoryLap() == 0 then -- not challenge, seeded run, or victory lap
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

function mod:isInGame()
  if REPENTOGON then
    return Isaac.IsInGame()
  end
  
  return true
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCmd)

----------------------
-- start repentogon --
----------------------
if REPENTOGON then
  function mod:onRender()
    mod:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
    mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
    mod:setupImGui()
  end
  
  -- imgui
  function mod:setupImGui()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemWinStreak', ImGuiElement.MenuItem, '\u{f11e} Win Streak Shenanigans (+Eden Tokens)')
    ImGui.CreateWindow('shenanigansWindowWinStreak', 'Win Streak Shenanigans (+Eden Tokens)')
    ImGui.LinkWindowToElement('shenanigansWindowWinStreak', 'shenanigansMenuItemWinStreak')
    
    ImGui.AddTabBar('shenanigansWindowWinStreak', 'shenanigansTabBarWinStreak')
    ImGui.AddTab('shenanigansTabBarWinStreak', 'shenanigansTabWinStreak', 'Win Streak')
    ImGui.AddTab('shenanigansTabBarWinStreak', 'shenanigansTabDailyStreak', 'Daily Streak')
    ImGui.AddTab('shenanigansTabBarWinStreak', 'shenanigansTabEdenTokens', 'Eden Tokens')
    
    ImGui.AddText('shenanigansTabWinStreak', 'Win Streak:', false)
    ImGui.AddInputInteger('shenanigansTabWinStreak', 'shenanigansIntWinStreak', '', nil, 0, 1, 100)
    ImGui.AddCallback('shenanigansIntWinStreak', ImGuiCallback.Render, function()
      local gameData = Isaac.GetPersistentGameData()
      local streakCounter = gameData:GetEventCounter(EventCounter.STREAK_COUNTER)
      if streakCounter == 0 then
        streakCounter = gameData:GetEventCounter(EventCounter.NEGATIVE_STREAK_COUNTER) * -1
      end
      ImGui.UpdateData('shenanigansIntWinStreak', ImGuiData.Value, streakCounter)
    end)
    ImGui.AddCallback('shenanigansIntWinStreak', ImGuiCallback.Edited, function(num)
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
    
    for _, v in ipairs({
                        { tab = 'shenanigansTabWinStreak'  , text = 'Best Win Streak:', field = 'shenanigansIntBestWinStreak', counter = EventCounter.BEST_STREAK },
                        { tab = 'shenanigansTabDailyStreak', text = 'Daily Streak:'   , field = 'shenanigansIntDailysStreak' , counter = EventCounter.DAILYS_STREAK },
                        { tab = 'shenanigansTabDailyStreak', text = 'Total Played:'   , field = 'shenanigansIntDailysPlayed' , counter = EventCounter.DAILYS_PLAYED },
                        { tab = 'shenanigansTabDailyStreak', text = 'Total Won:'      , field = 'shenanigansIntDailysWon'    , counter = EventCounter.DAILYS_WON },
                        { tab = 'shenanigansTabEdenTokens' , text = 'Eden Tokens:'    , field = 'shenanigansIntEdenTokens'   , counter = EventCounter.EDEN_TOKENS },
                      })
    do
      ImGui.AddText(v.tab, v.text, false)
      ImGui.AddInputInteger(v.tab, v.field, '', nil, 0, 1, 100)
      ImGui.AddCallback(v.field, ImGuiCallback.Render, function()
        local gameData = Isaac.GetPersistentGameData()
        ImGui.UpdateData(v.field, ImGuiData.Value, gameData:GetEventCounter(v.counter))
      end)
      ImGui.AddCallback(v.field, ImGuiCallback.Edited, function(num)
        local gameData = Isaac.GetPersistentGameData()
        gameData:IncreaseEventCounter(v.counter, num - gameData:GetEventCounter(v.counter))
      end)
    end
  end
  
  -- console
  function mod:registerCommands()
    Console.RegisterCommand('win-streak', 'Increment your win streak (win-streak +1)', 'Increment your win streak (win-streak +1)', false, AutocompleteType.NONE)
    Console.RegisterCommand('eden-tokens', 'Increment your eden tokens (eden-tokens +1)', 'Increment your eden tokens (eden-tokens +1)', false, AutocompleteType.NONE)
  end
  
  mod:registerCommands()
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
end
--------------------
-- end repentogon --
--------------------