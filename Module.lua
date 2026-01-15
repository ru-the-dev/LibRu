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
---@field Parent? LibRu.Module Parent module, if any
---@field Modules table<string, LibRu.Module> Sub-modules registered under this module
local Module = {
    DebugFunc = nil
}
Module.__index = Module


---@param name string Name of the module
---@param parent? LibRu.Module Optional parent module
---@return LibRu.Module
function Module.New(name, parent)
    ---@class LibRu.Module
    local t = setmetatable({
        Name = name,
        Enabled = true,
        Parent = nil,
        Modules = {}
    }, Module)
    

    if parent ~= nil then
        t.Parent = parent
        parent:AddChildModule(t)
    end

    return t
end

function Module:DebugLog(message)
    if self.DebugFunc then
        self.DebugFunc("Module [" .. tostring(self.Name) .. "]: " .. tostring(message))
    end
end

---@param module LibRu.Module Module to add as child
---@return LibRu.Module The added child module
function Module:AddChildModule(module)
    self.Modules[module.Name] = module

    return module
end


function Module:Remove()
    if self.Parent == nil then
        error("Cannot remove module '" .. tostring(self.Name) .. "' as it has no parent.")
        return
    end

    self.Parent.Modules[self.Name] = nil
    self.Parent = nil;
end

-- Virtual hook: modules should implement this for their own init logic.
-- It can be overridden; default does nothing.
---@virtual
function Module:OnInitialize() end

function Module:Initialize(...)
    self.OnInitialize(self)

    -- initialize children
    for name, child in pairs(self.Modules or {}) do
        if type(child.Initialize) == "function" then
            child.Initialize(child, ...)
        end
    end
end

LibRu.Module = Module