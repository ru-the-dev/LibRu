---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end


---@class LibRu.Module
---@field DebugFunc? fun(string) Optional debug function for logging
---@field Name string Name of the module
---@field Enabled boolean Whether the module is enabled
---@field Settings table Settings table for the module
local Module = {
    DebugFunc = nil
}
Module.__index = Module


---@param name string Name of the module
---@return LibRu.Module
function Module.New(name)
    ---@class LibRu.Module
    local t = setmetatable({
        Name = name,
        Enabled = true,
        Settings = {}
    }, Module)

    return t
end

function Module:DebugLog(message)
    if self.DebugFunc then
        self.DebugFunc("Module [" .. tostring(self.Name) .. "]: " .. tostring(message))
    end
end

-- Virtual hook: modules should implement this for their own init logic.
-- It can be overridden; default does nothing.
---@virtual
function Module:OnInitialize() end

function Module:Initialize()
    self:DebugLog("Initializing module.");

    self:OnInitialize()
end

LibRu.Module = Module