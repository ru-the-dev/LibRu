local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu



---@param command string The slash command to register
---@param handler function|table<string,function> The handler function or table of subcommand handlers
function LibRu.RegisterSlashCommand(command, handler)
    if not command or not handler then return end
    local cmd = command:lower()
    LibRu._registeredCommands = LibRu._registeredCommands or {}
    if LibRu._registeredCommands[cmd] then return end -- already registered
    LibRu._registeredCommands[cmd] = true
    local name = "LIBRU" .. cmd:gsub("/", ""):upper()
    _G["SLASH_" .. name .. "1"] = command
    
    local actualHandler = handler
    if type(handler) == "table" then
        actualHandler = function(msg, editbox)
            local subcmd = select(1, strsplit(" ", msg)) or ""
            local subhandler = handler[subcmd] or handler[""] or handler.default
            if subhandler then
                subhandler(msg, editbox)
            end
        end
    end
    SlashCmdList[name] = actualHandler
end