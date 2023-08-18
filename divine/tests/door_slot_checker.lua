local enableDisable = {}
Divine._private.Experiments.EnableDisable = enableDisable

local function doorTypeName(doorType)
    for k, v in pairs(DoorSlot) do
        if v == doorType then
            return k
        end
    end
end

function enableDisable:Handle()
    local player = Isaac.GetPlayer()
    if Input.IsButtonTriggered(Keyboard.KEY_F8, 0) then
        local doors = ""
        for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
            local door = Divine.Game:GetRoom():GetDoor(i)
            if door then
                doors = doors .. (doorTypeName(i) or tostring(i)) .. " "
            end
        end

        print(doors)
    end
end

--Divine:AddCallback(ModCallbacks.MC_POST_RENDER, enableDisable.Handle)