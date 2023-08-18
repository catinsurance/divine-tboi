local enableDisable = {}
Divine._private.Experiments.EnableDisable = enableDisable

local lol = true
function enableDisable:Handle()
    local player = Isaac.GetPlayer()
    if Input.IsButtonTriggered(Keyboard.KEY_F8, player.ControllerIndex) then
        local save = Divine._private.SaveManager.GetRoomSave()

        if save then
            local slot = Divine._private.FindAvailableDoorSlot()
            if slot then
                local seed = Divine.Game:GetSeeds():GetStartSeed()
                Divine._private.SpawnDealRoom(slot, seed, false)
            else
                Divine.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
            end
        end
    end

    if Input.IsButtonTriggered(Keyboard.KEY_F7, player.ControllerIndex) then
        if Divine.GetKrampusChance() == 1 then
            Divine.SetKrampusChance(0)
        else
            Divine.SetKrampusChance(1)
        end

        print(Divine.GetKrampusChance())
    end
end

Divine:AddCallback(ModCallbacks.MC_POST_RENDER, enableDisable.Handle)