Divine = RegisterMod("Divine (Devil and Angel library)", 1)
Divine._private = {}

Divine.Game = Game()
Divine.SFXManager = SFXManager()
Divine._private.Experiments = {}
Divine._private.SaveManager = include("divine.core.save_data")
Divine._private.SaveManager.Init(Divine)

Divine.Enum = {}

local isLoaded = true

function Divine:IsLoaded()
    return isLoaded
end

-- Include files

include("divine.enums.doors")
include("divine.enums.krampus")

include("divine.core.scheduler")
include("divine.core.math")

include("divine.core.rooms")
include("divine.core.krampus")
include("divine.core.default_behavior_disabler")
include("divine.core.deal_spawner")

include("divine.public.doors")
include("divine.public.devildeals")

include("divine.tests.enable_disable")
include("divine.tests.door_slot_checker")

--[[
    The average modder should only use the public methods, and those using private methods
    are probably contributing to the library itself.

    To prevent confusion and to keep things organized, the private methods - methods that only
    the mod needs to use - are in the "_private" table. Public methods are a part of the main
    Divine table.

    - catinsurance
]]--

-- Finish loading

isLoaded = true