
local slotsToCheck = {
    [RoomShape.ROOMSHAPE_1x1] = {
        DoorSlot.LEFT0,
        DoorSlot.RIGHT0,
        DoorSlot.UP0,
        DoorSlot.DOWN0,
    },
    [RoomShape.ROOMSHAPE_IH] = {
        DoorSlot.LEFT0,
        DoorSlot.RIGHT0,
    },
    [RoomShape.ROOMSHAPE_IV] = {
        DoorSlot.UP0,
        DoorSlot.DOWN0,
    },
    [RoomShape.ROOMSHAPE_1x2] = {
        DoorSlot.UP0,
        DoorSlot.DOWN0,
    },
    [RoomShape.ROOMSHAPE_IIV] = {
        DoorSlot.UP0,
        DoorSlot.DOWN0,
    },
    [RoomShape.ROOMSHAPE_2x2] = {
        DoorSlot.UP0,
        DoorSlot.DOWN0,
        DoorSlot.LEFT0,
        DoorSlot.RIGHT0,
        DoorSlot.UP1,
        DoorSlot.DOWN1,
        DoorSlot.LEFT1,
        DoorSlot.RIGHT1,
    },
    [RoomShape.ROOMSHAPE_LTL] = {
        DoorSlot.UP1,
        DoorSlot.RIGHT0,
        DoorSlot.RIGHT1,
        DoorSlot.DOWN0,
        DoorSlot.DOWN1,
        DoorSlot.LEFT1
    },
    [RoomShape.ROOMSHAPE_LTR] = {
        DoorSlot.UP0,
        DoorSlot.LEFT0,
        DoorSlot.LEFT1,
        DoorSlot.DOWN0,
        DoorSlot.DOWN1,
        DoorSlot.RIGHT1
    },
    [RoomShape.ROOMSHAPE_LBR] = {
        DoorSlot.UP0,
        DoorSlot.UP1,
        DoorSlot.RIGHT0,
        DoorSlot.DOWN0,
        DoorSlot.LEFT0,
        DoorSlot.LEFT1
    }
}

--- Returns every empty slot a door can spawn in a room.
---@return DoorSlot[]
function Divine.GetPossibleDoorSlots()
    local room = Divine.Game:GetRoom()
    local shape = room:GetRoomShape()

    local check = {table.unpack(slotsToCheck[shape])}

    for i in ipairs(check) do
        if room:GetDoor(DoorSlot.NO_DOOR_SLOT) then
            table.remove(check, i)
        end
    end

    return check
end