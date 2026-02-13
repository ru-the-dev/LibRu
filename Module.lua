local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

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
    local instance = setmetatable({
        Name = name,
        Debug = (debug == nil) and (parentModule and parentModule.Debug or false) or debug,
        Enabled = true,
        Settings = {},
        Dependencies = dependencies,
        Initialized = false,
        Initializing = false,
        ParentModule = parentModule or nil,
        Modules = {},
    }, Module)

    -- Register this module as a submodule of its parent, if applicable
    if parentModule then
        parentModule.Modules[name] = instance
    end

    instance.DebugColor = LibRu.Colors.GetNextDebugColor();
    instance.LogContext = LibRu.Logging.LogContext.New(instance:GetFullName(true), "DISPLAY", "INFO", "WARNING", "ERROR");

    return instance
end

---@param colored? boolean Whether to return colored names (defaults to false)
function Module:GetFullName(colored)
    local parts = {}
    local current = self
    while current do
        local name = tostring(current.Name)
        local coloredName = name
        if colored and current.DebugColor then
            coloredName = LibRu.Colors.ChatFormat(current.DebugColor, name, true)
        end
        table.insert(parts, 1, coloredName)  -- Insert at beginning to build from root to leaf
        current = current.ParentModule
    end
    return table.concat(parts, ".")
end

function Module:DebugLog(message)
    if self.Debug then
        LibRu.Logging.LogDisplay(tostring(message), self.LogContext)
    end
end

---@param level LibRu.Logging.LogLevel
---@param message string
function Module:Log(level, message)
    LibRu.Logging.Log(level, message, self.LogContext)
end

---@param message string
function Module:LogDisplay(message)
    LibRu.Logging.LogDisplay(message, self.LogContext)
end

---@param message string
function Module:LogInfo(message)
    LibRu.Logging.LogInfo(message, self.LogContext)
end

---@param message string
function Module:LogWarning(message)
    LibRu.Logging.LogWarning(message, self.LogContext)
end

---@param message string
function Module:LogError(message)
    LibRu.Logging.LogError(message, self.LogContext)
end


-- Virtual hook: modules should implement this for their own init logic.
-- It can be overridden; default does nothing.
---@virtual
function Module:OnInitialize() end

function Module:Initialize()
    if self.Initialized or self.Initializing then return end

    self.Initializing = true

    self:DebugLog("Initializing module.")

    -- Initialize dependencies first
    for _, dependency in ipairs(self.Dependencies) do
        if dependency.Initializing and not dependency.Initialized then
            self:DebugLog("Dependency already initializing: " .. dependency:GetFullName())
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