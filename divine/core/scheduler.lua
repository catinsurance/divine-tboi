local scheduled = {}

function Divine._private.Schedule(delay, callback, ...)
    table.insert(scheduled, {
        When = Divine.Game:GetFrameCount() + delay,
        Callback = callback,
        Args = table.pack(...)
    })
end

function Divine._private.Defer(callback, ...)
    Divine._private.Schedule(1, callback, ...)
end

local function empty()
    scheduled = {}
end

local function update()
    for index, task in ipairs(scheduled) do
        if task.When < Divine.Game:GetFrameCount() then
            task.Callback(table.unpack(task.Args))
            table.remove(scheduled, index)
        end
    end
end

Divine:AddCallback(ModCallbacks.MC_POST_RENDER, update)
Divine:AddCallback(ModCallbacks.MC_POST_GAME_END, empty)
Divine:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, empty)