---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

-- Debug color queue (hex RRGGBB strings). Modules will be assigned colors round-robin.
LibRu.DebugColors = LibRu.DebugColors or {
    "ffd166", -- warm yellow
    "06d6a0", -- teal
    "118ab2", -- blue
    "073b4c", -- dark teal
    "ef476f", -- pink/red
    "8a2be2", -- purple
    "00ff7f", -- spring green
}
LibRu._nextDebugColorIndex = LibRu._nextDebugColorIndex or 1


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

    -- Assign a rotating debug color to this module
    local colorHex = LibRu.DebugColors[LibRu._nextDebugColorIndex] or "ffffff"
    LibRu._nextDebugColorIndex = (LibRu._nextDebugColorIndex % #LibRu.DebugColors) + 1
    t.DebugColorHex = colorHex
    t.DebugColorPrefix = "|cff" .. colorHex
    t.DebugColorSuffix = "|r"

    return t
end

function Module:DebugLog(message)
    if self.DebugFunc then
        local name = tostring(self.Name)
        local coloredName = name
        if self.DebugColorHex then
            coloredName = (self.DebugColorPrefix or "|cffFFFFFF") .. name .. (self.DebugColorSuffix or "|r")
        end
        self.DebugFunc("Module [" .. coloredName .. "]: " .. tostring(message))
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