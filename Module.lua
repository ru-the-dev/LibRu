local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu
local Logging = LibRu.Logging
if not Logging then
    error("LibRu.Logging not loaded. Check LibRu/Debug/Load.xml order.")
end

---@class LibRu.Module
---@field Name string Name of the module
---@field Enabled boolean Whether the module is enabled
---@field Settings table Settings table for the module
---@field Dependencies LibRu.Module[] List of modules this module depends on
local Module = {}

Module.__index = Module


---@param name string Name of the module
---@param parentModule? LibRu.Module Optional parent module
---@param dependencies? LibRu.Module[] Optional list of dependencies
---@param debug? boolean should debugging be enabled for this module
---@return LibRu.Module
function Module.New(name, parentModule, dependencies, debug)
    -- Validate dependencies exist at creation time
    dependencies = dependencies or {}
    for i, dep in ipairs(dependencies) do
        if not dep then
            error(string.format("Module '%s': dependency at index %d is nil", name, i))
        end
    end

    ---@class LibRu.Module
    local t = setmetatable({
        Name = name,
        Debug = (debug == nil) and (parentModule and parentModule.Debug or false) or debug,
        Enabled = true,
        Settings = {},
        Dependencies = dependencies,
        Initialized = false,
        Initializing = false,
        ParentModule = parentModule or nil,
        Modules = {}
    }, Module)

    if parentModule and parentModule.Logger then
        t.Logger = parentModule.Logger
    else
        t.Logger = Logging.GetLogger(t)
    end

    -- Register this module as a submodule of its parent, if applicable
    if parentModule then
        parentModule.Modules[name] = t
    end

    -- Assign a rotating debug color to this module
    local colorHex = LibRu.GetNewDebugColorHex and LibRu.GetNewDebugColorHex() or "ffffff"
    t.DebugColorHex = colorHex
    t.DebugColorPrefix = "|cff" .. colorHex
    t.DebugColorSuffix = "|r"

    return t
end

---@param colored? boolean Whether to return colored names (defaults to false)
function Module:GetFullName(colored)
    local parts = {}
    local current = self
    while current do
        local name = tostring(current.Name)
        local coloredName = name
        if colored and current.DebugColorHex then
            coloredName = (current.DebugColorPrefix or "|cffFFFFFF") .. name .. (current.DebugColorSuffix or "|r")
        end
        table.insert(parts, 1, coloredName)  -- Insert at beginning to build from root to leaf
        current = current.ParentModule
    end
    return table.concat(parts, ".")
end

function Module:Initialize()
    if self.Initialized or self.Initializing then return end

    self.Initializing = true

    self:LogInfo("Initializing module.")

    -- Initialize dependencies first
    for _, dependency in ipairs(self.Dependencies) do
        if dependency.Initializing and not dependency.Initialized then
            self:LogWarning("Dependency already initializing: " .. dependency:GetFullName())
        elseif not dependency.Initialized then
            dependency:Initialize()
        end
    end

    self:OnInitialize()

    self.Initialized = true

    --- initialize submodules
    for _, subModule in pairs(self.Modules) do
        subModule:Initialize()
    end

    self.Initializing = false
end

-- Virtual hook: modules should implement this for their own init logic.
-- It can be overridden; default does nothing.
---@virtual
function Module:OnInitialize() end


function Module:Log(level, message)
    local levelName = Logging.NormalizeLevel(level)
    if not levelName then
        error("Invalid log level: " .. tostring(level))
    end
    local logger = self.Logger or Logging.GetLogger(self)
    if logger and not logger:IsEnabled(levelName) then
        return
    end
    local coloredFullName = self:GetFullName(true)
    local levelLabel = logger and logger:GetLevelLabel(levelName) or Logging.GetLevelLabel(levelName)
    print("[" .. coloredFullName .. "] " .. levelLabel .. ": " .. tostring(message))
end

function Module:LogDisplay(message)
    self:Log("DISPLAY", message)
end

function Module:LogInfo(message)
    self:Log("INFO", message)
end

function Module:LogWarning(message)
    self:Log("WARNING", message)
end

function Module:LogError(message)
    self:Log("ERROR", message)
end

function Module:SetLogLevel(level)
    local logger = self.Logger or Logging.GetLogger(self)
    if not logger then return end
    logger:SetLevel(level)
end

function Module:GetLogLevel()
    local logger = self.Logger or Logging.GetLogger(self)
    if not logger then return end
    return logger.Level
end

--- Safely gets a nested submodule by dot-separated path, returning nil if any level is missing.
--- @param path? string The dot-separated path to the module (e.g., "WardrobeCollection.CollectionLayout").
--- @return LibRu.Module|nil The nested module, or nil if not found.
function Module:GetModule(path)
    
    if path == nil then return self end

    if type(path) ~= "string" then
        error("GetModule path must be a string or nil.")
    end

    local keys = {}
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end
    local current = self
    for _, key in ipairs(keys) do
        if not current or not current.Modules then return nil end
        current = current.Modules[key]
    end
    return current
end

LibRu.Module = Module