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
    if not game:IsGreedMode() and not seeds:IsCustomRun() then -- not greed mode, challenge, or seeded run
      if string.len(parameters) >= 2 and string.sub(parameters, 1, 1) == '+' then
        local num = tonumber(string.sub(parameters, 2))
        
        if math.type(num) == 'integer' and num > 0 and num <= max then
          Isaac.ExecuteCommand('stage 8') -- womb 2
          
          level.LeaveDoor = DoorSlot.NO_DOOR_SLOT
          game:ChangeRoom(level:GetRooms():Get(level:GetLastBossRoomListIndex()).SafeGridIndex, -1) -- mom's heart / it lives
          
          for i = 1, num do
            room:TriggerClear(true)
          end
          
          game:End(3) -- Mom's Heart endings
          
          print('+' .. num)
          return
        end
      end
    end
    
    print('+0')
  end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCmd)