local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

if not LibRu.Logging.LogContext then
    error("LibRu.Logging.LogContext is required for LibRu.Logging")
    return;
end

--- ======================================================
--- LibRu.Logging
--- ======================================================

--- @class LibRu.Logging
local Logging = LibRu.Logging or {}
LibRu.Logging = Logging;

local globalContext = Logging.LogContext.New("LibRu",
    "INFO",
    "WARNING",
    "ERROR"
);

---@param level LibRu.Logging.LogLevel
---@param message string
---@param context? LibRu.LogContext
function Logging.Log(level, message, context)
    context = context or globalContext;

    if not context.Enabled then return end

    --- early out if the logging level is not enabled for this context.
    if not context:AreLevelsEnabled(level) then return end

    -- get the level definition (contains value and color)
    local levelDefinition = Logging.LOG_LEVELS[level];
    if not levelDefinition then 
        error("Invalid log level: " .. level);   
        return;
    end;

    -- format like so: [LEVEL] > [ContextName] : Message
    local levelText = LibRu.Colors.ChatFormat(levelDefinition.Color, "[" .. level .. "]", false)
    print(string.format("%s > [%s] : %s", levelText, context.Name, message))
end

---@param message string
---@param context? LibRu.LogContext
function Logging.LogInfo(message, context)
    Logging.Log("INFO", message, context)
end

---@param message string
---@param context? LibRu.LogContext
function Logging.LogWarning(message, context)
    Logging.Log("WARNING", message, context)
end

---@param message string
---@param context? LibRu.LogContext
function Logging.LogError(message, context)
    Logging.Log("ERROR", message, context)
end