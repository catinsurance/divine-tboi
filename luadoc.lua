---@diagnostic disable

Divine = {}

include = require

---@param callback ModCallbacks | CustomCallback
---@param func function
---@param ... any
function Divine:AddCallback(callback, func, ...) end

---@param callback ModCallbacks | CustomCallback
---@param priority CallbackPriority
---@param func function
function Divine:AddPriorityCallback(callback, priority, func) end

---@return boolean
function Divine:HasData() end

---@return string
function Divine:LoadData() end

---@param callback ModCallbacks | CustomCallback
---@param func function
function Divine:RemoveCallback(callback, func) end

---Generally, don't do this.
function Divine:RemoveData() end

---@param data string
function Divine:SaveData(data) end

---@type string
Divine.Name = ""