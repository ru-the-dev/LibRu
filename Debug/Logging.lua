local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

--- @class LibRu.Logging.LevelMeta
--- @field Value integer Severity value (lower is more verbose)
--- @field Color string Hex color for the level label (RRGGBB)

--- @class LibRu.Logging
--- @field Level integer Global level threshold
local Logging = {}
LibRu.Logging = Logging;

---@enum LibRu.Logging.LogLevel
local LOG_LEVEL = {
    DISPLAY = 0,
    INFO = 2,
    WARNING = 4,
    ERROR = 8,
}

local globalLogLevel = LibRu.EnumFlag.Create(LOG_LEVEL)


-- Example: set default enabled levels (LSP should autocomplete the string literals)
globalLogLevel:SetFlags(LOG_LEVEL.DISPLAY)

local Loggers = {}





--- Resolve the top-level addon key for a module or explicit name.
--- @param context string|table|nil Addon name or module table
--- @return string|nil Addon key or nil if not resolvable
function Logging.GetAddonKey(context)
    if type(context) == "string" then
        return context
    end
    if type(context) ~= "table" then
        return nil
    end

    local current = context
    while current and current.ParentModule do
        current = current.ParentModule
    end

    if current and current.Name then
        return tostring(current.Name)
    end
    return nil
end

--- Return a cached logger for the addon/module.
--- @param context string|table|nil Addon name or module table
--- @return table|nil Logger instance or nil if not resolvable
function Logging.GetLogger(context)
    local name = nil
    if type(context) == "string" then
        name = context
    elseif type(context) == "table" and type(context.GetFullName) == "function" then
        name = context:GetFullName(false)
    end
    if not name then
        name = Logging.GetAddonKey(context)
    end
    if not name then return nil end
    if not Loggers[name] then
        local logger = {
            Name = name,
            Level = nil,
        }

        function logger:IsEnabled(level)
            local value = Logging.GetLevelValue(level)
            if not value then return false end
            local threshold = self.Level
            if threshold == nil then
                threshold = Logging.Level
            end
            return value >= threshold
        end

        function logger:SetLevel(level)
            local value = Logging.GetLevelValue(level)
            if not value then
                error("Invalid log level: " .. tostring(level))
            end
            self.Level = value
        end

        function logger:Log(level, message)
            if not self:IsEnabled(level) then return end
            local label = Logging.GetLevelLabel(level)
            print("[" .. self.Name .. "] " .. label .. ": " .. tostring(message))
        end

        Loggers[name] = logger
    end
    return Loggers[name]
end

--- Check if a level is enabled for the addon/module.
--- @param level string|integer Level name or value
--- @param context string|table|nil Addon name or module table
--- @return boolean True when enabled
function Logging.IsLevelEnabled(level, context)
    local logger = Logging.GetLogger(context)
    if logger then
        return logger:IsEnabled(level)
    end
    return false
end

--- Set the global level threshold.
--- @param level string|integer Level name or value
function Logging.SetLevel(level)
    globalLogLevel = level;
end

--- Get the global level threshold.
--- @return integer Level bit flag for enabled levels value
function Logging.GetLevelsFlag()
    return globalLogLevel;
end

--- Get the colored label for a log level.
--- @param level string
--- @return string Colored label text
function Logging.GetLevelLabel(level)
    if not level then return "UNKNOWN" end
    
    local color = logLevelData[level] and logLevelData[level].Color or nil
    if color then
        return "|cff" .. color .. level .. "|r"
    end
    return level
end
