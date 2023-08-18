-- This effect is invisible and will be removed when initialized
Divine._private.EmptyTemporaryEffect = Isaac.GetEntityVariantByName("Entity Effect Cancellation")

---@param door GridEntityDoor
function Divine._private.HideDoor(door)
    door:Close(true)

    -- first time closing
    if door:GetSprite():GetFilename() ~= "" then
        Divine.SFXManager:Stop(SoundEffect.SOUND_DEVILROOM_DEAL)
        Divine.SFXManager:Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
    end

    door:GetSprite():Load("", true)
end

function Divine._private.FindNearestDoor(position)
    local room = Divine.Game:GetRoom()

    local closest, closestDistance = nil, math.huge
    for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
        local door = room:GetDoor(i)

        if door then
            local distance = (door.Position - position):Length()

            if distance < closestDistance then
                closest = door
                closestDistance = distance
            end
        end
    end

    return closest
end

function Divine._private:DisableDealDoors()
    local room = Divine.Game:GetRoom()
    local roomSave = Divine._private.SaveManager.GetRoomSave()

    for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
        local door = room:GetDoor(i)

        if door and roomSave then
            if door.TargetRoomType == RoomType.ROOM_DEVIL and not roomSave.AllowDevilDoor then
                room:RemoveDoor(i)
                Divine.SFXManager:Stop(SoundEffect.SOUND_SATAN_ROOM_APPEAR)
            end

            if door.TargetRoomType == RoomType.ROOM_ANGEL and not roomSave.AllowAngelDoor then
                room:RemoveDoor(i)
                Divine.SFXManager:Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
            end
        end
    end
end

Divine:AddCallback(ModCallbacks.MC_POST_UPDATE, Divine._private.DisableDealDoors)

-- Cancels spawning the dust cloud poof that appears when a deal door appears
function Divine._private:CancelDealPoof(entityType, variant, _, position, _, _, seed)

    if entityType ~= EntityType.ENTITY_EFFECT then
        return
    end

    if variant ~= EffectVariant.DUST_CLOUD then
        return
    end

    local roomSave = Divine._private.SaveManager.GetRoomSave()
    if roomSave then
        local door = Divine._private.FindNearestDoor(position)
        if door then
            if door.TargetRoomType == RoomType.ROOM_DEVIL and not roomSave.ShouldShowDevil then
                return {EntityType.ENTITY_EFFECT, Divine._private.EmptyTemporaryEffect, seed}
            end

            if door.TargetRoomType == RoomType.ROOM_ANGEL and not roomSave.ShouldShowAngel then
                return {EntityType.ENTITY_EFFECT, Divine._private.EmptyTemporaryEffect, seed}
            end
        end
    end
end

Divine:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, Divine._private.CancelDealPoof)

function Divine._private:RemoveTemporaryEffect(effect)
    effect:Remove()
end

Divine:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Divine._private.RemoveTemporaryEffect, Divine._private.EmptyTemporaryEffect)

function Divine._private:CancelKrampus(entityType, variant)
    local floorSave = Divine._private.SaveManager.GetFloorSave(nil, true)
    if floorSave then
        -- 1 is krampus
        if entityType == EntityType.ENTITY_FALLEN and variant == 1 then
            if floorSave.KrampusDefeated then
                -- effects are 999 in this callback
                return {999, Divine._private.EmptyTemporaryEffect, 0}
            end
        end
    end
end

Divine:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, Divine._private.CancelKrampus)