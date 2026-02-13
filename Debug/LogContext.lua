local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

if not LibRu.Colors then
    error("LibRu.Colors is required for LibRu.Logging.LogContext")
    return;
end

---@class LibRu.Logging
LibRu.Logging = LibRu.Logging or {};

---@alias LibRu.Logging.LogLevel "INFO" | "WARNING" | "ERROR"
LibRu.Logging.LOG_LEVELS = {
    INFO = {
        Value = bit.lshift(1, 0),
        Color = LibRu.Colors.All.LightSkyBlue,
    },
    WARNING = {
        Value = bit.lshift(1, 1),
        Color = LibRu.Colors.All.Gold,
    },
    ERROR = {
        Value = bit.lshift(1, 2),
        Color = LibRu.Colors.All.Red,
    }
}

--- ======================================================
--- LibRu.LogContext
--- ======================================================
---@class LibRu.LogContext
---@field Name string
---@field LogLevelFlag number
---@field Enabled boolean
local LogContext = {}

LibRu.Logging.LogContext = LogContext;
LogContext.__index = LogContext;


--- ======================================================
--- Factory
--- ======================================================

---@param name string
---@param ... LibRu.Logging.LogLevel Levels to enable for this context
---@return LibRu.LogContext
function LogContext.New(name, ...)
    local instance = setmetatable({}, LogContext)

    instance.Name = name or "Unnamed"
    instance.LogLevelFlag = 0;
    instance.Enabled = true;

    instance:EnableLevels(...)
    return instance
end

--- ======================================================
--- Configuration
--- ======================================================

---@param ... LibRu.Logging.LogLevel
function LogContext:EnableLevels(...)
    local levels = {...}
    
    for _, level in ipairs(levels) do
        local levelDefinition = LibRu.Logging.LOG_LEVELS[level]
        if levelDefinition then 
            self.LogLevelFlag = bit.bor(self.LogLevelFlag, levelDefinition.Value)
        end
    end
    
end

---@param ... LibRu.Logging.LogLevel
function LogContext:DisableLevels(...)
    local levels = {...}
    
    for _, level in ipairs(levels) do
        local levelDefinition = LibRu.Logging.LOG_LEVELS[level]
        if levelDefinition then 
            self.LogLevelFlag = bit.band(self.LogLevelFlag, bit.bnot(levelDefinition.Value))
        end
    end
end

---@param ... LibRu.Logging.LogLevel
---@return boolean
function LogContext:AreLevelsEnabled(...)
    local levels = {...}
    for _, level in ipairs(levels) do
        local levelDefinition = LibRu.Logging.LOG_LEVELS[level]
        if not levelDefinition then return false end
        if bit.band(self.LogLevelFlag, levelDefinition.Value) == 0 then
            return false
        end
    end
    return true
end
