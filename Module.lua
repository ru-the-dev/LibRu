---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- LibStub handles version checking, so no need for ShouldLoad check


---@class LibRu.Module
---@field Name string Name of the module
---@field Enabled boolean Whether the module is enabled
---@field Settings table Settings table for the module
---@field Commands table<string, function|table<string,function>> Table of slash commands and their handlers or subcommand tables
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
        Debug = debug or parentModule and parentModule.Debug or false,
        Enabled = true,
        Settings = {},
        Commands = {},
        Dependencies = dependencies,
        Initialized = false,
        ParentModule = parentModule or nil,
        Modules = {}
    }, Module)

    -- Register this module as a submodule of its parent, if applicable
    if parentModule then
        parentModule.Modules[name] = t
    end

    -- Assign a rotating debug color to this module
    local colorHex = LibRu.DebugColors[LibRu._nextDebugColorIndex] or "ffffff"
    LibRu._nextDebugColorIndex = (LibRu._nextDebugColorIndex % #LibRu.DebugColors) + 1
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

function Module:DebugLog(message)
    if self.Debug then
        local coloredFullName = self:GetFullName(true)
        print("Module [" .. coloredFullName .. "]: " .. tostring(message))
    end
end

-- Virtual hook: modules should implement this for their own init logic.
-- It can be overridden; default does nothing.
---@virtual
function Module:OnInitialize() end

function Module:Initialize()
    if self.Initialized then return end

    self:DebugLog("Initializing module.")

    -- Initialize dependencies first
    for _, dependency in ipairs(self.Dependencies) do
        if not dependency.Initialized then
            dependency:Initialize()
        end
    end

    self:OnInitialize()

    self.Initialized = true
    
    -- Register slash commands defined in this module
    for command, handler in pairs(self.Commands) do
        self:RegisterSlashCommand(command, handler)
    end
    
    --- initialize submodules
    for _, subModule in pairs(self.Modules) do
        subModule:Initialize()
    end

    
end

---@param command string The slash command (e.g., "/mymodule")
---@param handler function|table<string,function> The handler function or table of subcommand handlers
function Module:RegisterSlashCommand(command, handler)
    LibRu.RegisterSlashCommand(command, handler)
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