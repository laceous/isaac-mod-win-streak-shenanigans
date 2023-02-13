local mod = RegisterMod('Win Streak Shenanigans', 1)
local game = Game()

-- usage: win-streak +10
function mod:onExecuteCmd(cmd, parameters)
  cmd = string.lower(cmd)
  
  if cmd == 'win-streak' then
    local seeds = game:GetSeeds()
    local max = 9999 -- 4 digits
    
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
  end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.onExecuteCmd)