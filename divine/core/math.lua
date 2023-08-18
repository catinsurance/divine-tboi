function Divine._private.Clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    end

    return x
end