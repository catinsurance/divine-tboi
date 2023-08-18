Divine._private.KrampusRooms = {
    2300,
    2301,
    2302,
    2303,
    2304,
    2307
}


Divine._private.KrampusChance = Divine.Enum.DEFAULT_KRAMPUS_CHANCE

---@param rng RNG
function Divine._private.GetKrampusRoom(rng)
    local index = rng:RandomInt(#Divine._private.KrampusRooms) + 1
    return Divine._private.KrampusRooms[index]
end