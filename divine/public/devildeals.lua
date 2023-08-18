--- Get the chance for a Krampus fight to spawn. This is a float between 0 and 1.
function Divine.GetKrampusChance()
    return Divine._private.KrampusChance
end

--- Set the chance for a Krampus fight to spawn. This should be a float between 0 and 1.
function Divine.SetKrampusChance(chance)
    Divine._private.KrampusChance = Divine._private.Clamp(chance, 0, 1)
end