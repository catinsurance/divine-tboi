-- thank you StageAPI
local EFFECT_SUBTYPE_MOONLIGHT = 1 -- Luna light beam in secret rooms
local excludeTypesFromClearing = {
    [EntityType.ENTITY_FAMILIAR] = true,
    [EntityType.ENTITY_PLAYER] = true,
    [EntityType.ENTITY_KNIFE] = true,
    [EntityType.ENTITY_BLOOD_PUPPY] = true,
    [EntityType.ENTITY_DARK_ESAU] = true,
    [EntityType.ENTITY_MOTHERS_SHADOW] = true,
    [EntityType.ENTITY_FALLEN] = {
        [1] = true, -- krampus
    },
    [EntityType.ENTITY_EFFECT] = {
        [EffectVariant.HEAVEN_LIGHT_DOOR] = {
            [EFFECT_SUBTYPE_MOONLIGHT] = true,
        },
        [EffectVariant.BLOOD_SPLAT] = true,
        [EffectVariant.WISP] = true,
    },
}

local function shouldExcludeEntityFromClearing(entity)
    return excludeTypesFromClearing[entity.Type]
        or (
            type(excludeTypesFromClearing[entity.Type]) == "table"
            and excludeTypesFromClearing[entity.Type][entity.Variant]
        )
        or (
            type(excludeTypesFromClearing[entity.Type]) == "table"
            and type(excludeTypesFromClearing[entity.Type][entity.Variant]) == "table"
            and excludeTypesFromClearing[entity.Type][entity.Variant][entity.SubType]
        )
end

--- Spawns an angel room door at the given door slot
---@return boolean @true if the deal was spawned, false otherwise
function Divine._private.SpawnDealRoom(doorSlot, seed, isAngel)
    local room = Divine.Game:GetRoom()
    local level = Divine.Game:GetLevel()
    local runSave = Divine._private.SaveManager.GetRunSave(nil, true)
    local floorSave = Divine._private.SaveManager.GetFloorSave(nil, true)

    -- already exists
    if room:GetDoor(doorSlot) then
        return false
    end

    -- allow the door
    local roomSave = Divine._private.SaveManager.GetRoomSave()
    roomSave.AllowAngelDoor = true
    roomSave.AllowDevilDoor = true

    -- Uninitialize the devil room

    if level:GetCurrentRoomIndex() == GridRooms.ROOM_DEVIL_IDX then
        return false
    end


    if not (floorSave and floorSave.KrampusRoomGenerated) then
        runSave.ShouldRegenDevilRoom = false

        local roomDescriptor = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
        roomDescriptor.Flags = 0 -- wipe any clear
        roomDescriptor.Clear = false
        roomDescriptor.Data = nil

        -- spawn the door
        level:InitializeDevilAngelRoom(isAngel, not isAngel)
        roomDescriptor.SurpriseMiniboss = false
    end

    runSave.ShouldRegenDevilRoom = true

    -- spawn doors

    local doorSpawned = room:TrySpawnDevilRoomDoor(false, true)
    if not doorSpawned then
        roomSave.AllowAngelDoor = false
        roomSave.AllowDevilDoor = false
        return false
    end

    ---@type GridEntityDoor
    local door
    for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
        local candidate = room:GetDoor(i)
        if candidate and (candidate.TargetRoomType == RoomType.ROOM_DEVIL or candidate.TargetRoomType == RoomType.ROOM_ANGEL) then
            door = candidate
            break
        end
    end

    if not door then
        roomSave.AllowAngelDoor = false
        roomSave.AllowDevilDoor = false
        return false
    end


    local index = GridRooms.ROOM_DEVIL_IDX
    door.TargetRoomIndex = index
    door.TargetRoomType = isAngel and RoomType.ROOM_ANGEL or RoomType.ROOM_DEVIL

    -- finally, set the sprite of the door
    local spriteToUse = isAngel and Divine.Enum.DivineDoorSpritePath.ANGEL or Divine.Enum.DivineDoorSpritePath.DEVIL
    local sprite = door:GetSprite()
    sprite:Load(spriteToUse, true)
    sprite:Play("Opened", true)

    if isAngel then
        roomSave.AllowDevilDoor = false
    else
        roomSave.AllowAngelDoor = false
    end

    -- if krampus, set door to krampus
    local rng = level:GetDevilAngelRoomRNG()
    local floorSave = Divine._private.SaveManager.GetFloorSave(nil, true)
    if not isAngel
    and floorSave
    and not floorSave.KrampusRoomId
    and Divine._private.KrampusChance > 0
    and rng:RandomFloat() < Divine._private.KrampusChance then
        local roomId = Divine._private.GetKrampusRoom(rng)

        floorSave.KrampusRoomId = roomId
    end

    return true
end

function Divine._private.FindAvailableDoorSlot()
    local room = Divine.Game:GetRoom()
    local slots = Divine.GetPossibleDoorSlots()

    for _, slot in ipairs(slots) do
        if not room:GetDoor(slot) then
            return slot
        end
    end
end

function Divine._private:RegenerateDealRoom()
    local runSave = Divine._private.SaveManager.GetRunSave(nil, true)
    local floorSave = Divine._private.SaveManager.GetFloorSave(nil, true)
    local level = Divine.Game:GetLevel()
    local room = Divine.Game:GetRoom()

    if runSave and runSave.ShouldRegenDevilRoom then
        if room:GetType() == RoomType.ROOM_DEVIL or room:GetType() == RoomType.ROOM_ANGEL then

            local devil = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
            local roomConfigRoom = devil.Data

            local spawnList = roomConfigRoom.Spawns

            if floorSave and floorSave.KrampusRoomGenerated then
                return
            end

            -- remove teh statue
            if floorSave and floorSave.KrampusRoomGenerated then
                for i = 0, room:GetGridSize() do
                    local gridEntity = room:GetGridEntity(i)
                    if gridEntity and gridEntity:GetType() == GridEntityType.GRID_STATUE then
                        -- statues are glitched with their sprites so forcefully remove it
                        gridEntity:GetSprite():Reset()

                        room:RemoveGridEntity(i, 0, false)
                    end
                end

                for _, statue in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL)) do
                    statue:Remove()
                end

                for _, statue in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ANGEL)) do
                    statue:Remove()
                end

                return
            end

            if floorSave and floorSave.KrampusRoomData then
                Divine._private.RegenerateRoom(floorSave.KrampusRoomData.Spawns, devil.SpawnSeed, devil.DecorationSeed)
                floorSave.KrampusRoomGenerated = true
                return
            end

            -- clear the room first
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                local persistent = (entity:HasEntityFlags(EntityFlag.FLAG_CHARM) or entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT))
                if not shouldExcludeEntityFromClearing(entity) and not persistent then
                    entity:Remove()
                end
            end

            for i = 0, room:GetGridSize() do
                local gridEntity = room:GetGridEntity(i)
                if gridEntity and gridEntity:GetType() ~= GridEntityType.GRID_WALL and gridEntity:GetType() ~= GridEntityType.GRID_DOOR then
                    if gridEntity:GetType() == GridEntityType.GRID_STATUE then
                        -- statues are glitched with their sprites so forcefully remove it
                        gridEntity:GetSprite():Reset()
                    end

                    room:RemoveGridEntity(i, 0, false)
                end
            end

            -- finally, clear the statue effects, since theyre effects for some reason
            for _, statue in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL)) do
                statue:Remove()
            end

            for _, statue in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ANGEL)) do
                statue:Remove()
            end

            -- update
            room:Update()
            Divine.SFXManager:Stop(SoundEffect.SOUND_MOM_VOX_EVILLAUGH)

            if floorSave and floorSave.KrampusRoomId and not floorSave.KrampusRoomData then
                -- check if we can use the debug room
                Isaac.ExecuteCommand("goto s.miniboss." .. floorSave.KrampusRoomId)

                local debugRoom = level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)
                floorSave.KrampusRoomData = debugRoom.Data

                -- teleport back
                Divine.Game:StartRoomTransition(GridRooms.ROOM_DEVIL_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.WALK)
                return
            else
                Divine._private.RegenerateRoom(spawnList, devil.SpawnSeed, devil.DecorationSeed)
            end

            runSave.ShouldRegenDevilRoom = false
        end
    end
end

Divine:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Divine._private.RegenerateDealRoom)

