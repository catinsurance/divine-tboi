function Divine._private.RegenerateRoom(spawnList, spawnSeed, decorationSeed)
    local room = Divine.Game:GetRoom()
    local rng = RNG()
    rng:SetSeed(spawnSeed, 32)

    for i = 0, #spawnList do
        local roomConfigSpawn = spawnList:Get(i)
        if roomConfigSpawn then
            local entry = roomConfigSpawn:PickEntry(rng:RandomFloat())
            local topLeft = room:GetGridPosition(0) + (Vector.One * 40)
            if entry.Type < EntityType.ENTITY_EFFECT then
                local entity = Isaac.Spawn(entry.Type, entry.Variant, entry.Subtype, topLeft + Vector(roomConfigSpawn.X * 40, roomConfigSpawn.Y * 40), Vector.Zero, nil)
                entity:GetSprite():Update()
            else
                local gridIndex = room:GetGridIndex(topLeft + Vector(roomConfigSpawn.X * 40, roomConfigSpawn.Y * 40))
                Isaac.ExecuteCommand(("gridspawn %s %s"):format(entry.Type, gridIndex))
            end
        end
    end

    local backdropRng = RNG()
    backdropRng:SetSeed(decorationSeed, 32)
    for i = 0, Game():GetRoom():GetGridSize() do
        local gridEntity = Game():GetRoom():GetGridEntity(i)
        if gridEntity and gridEntity:GetType() == GridEntityType.GRID_PIT then
            gridEntity:PostInit()
        end

        -- decorations
        if not gridEntity then
            if backdropRng:RandomFloat() < 0.1 then
                room:SpawnGridEntity(i, GridEntityType.GRID_DECORATION, 0, decorationSeed, 0)
            end
        end
    end
end