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

-- =======================================================
-- Command Router
-- =======================================================

---@class LibRu.CommandRouter
LibRu.CommandRouter = LibRu.CommandRouter or {}

local Router = {}
Router.__index = Router

local function Trim(value)
    return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function ParseArgs(input)
    local args = {}
    local i = 1
    local len = #input

    while i <= len do
        while i <= len and input:sub(i, i):match("%s") do
            i = i + 1
        end

        if i > len then break end

        local char = input:sub(i, i)
        if char == '"' then
            i = i + 1
            local start = i
            local buffer = ""
            while i <= len do
                local c = input:sub(i, i)
                if c == '"' then
                    break
                elseif c == "\\" and i < len then
                    local nextChar = input:sub(i + 1, i + 1)
                    buffer = buffer .. nextChar
                    i = i + 2
                else
                    buffer = buffer .. c
                    i = i + 1
                end
            end
            table.insert(args, buffer)
            i = i + 1
        else
            local start = i
            while i <= len and not input:sub(i, i):match("%s") do
                i = i + 1
            end
            table.insert(args, input:sub(start, i - 1))
        end
    end

    return args
end

---@class LibRu.CommandRouter
---@field Name string
---@field BaseCommands string[]
---@field Subcommands table
---@field Aliases table<string, string>
---@field BaseCommandHandlers table<string, {handler: function, always: boolean}>
---@field DefaultHandler function|nil
---@field UnknownHandler function|nil

---@param name string
---@param options? {baseCommands?: string[]}
---@return LibRu.CommandRouter
function LibRu.CommandRouter.New(name, options)
    local t = setmetatable({
        Name = name or "CommandRouter",
        BaseCommands = {},
        Subcommands = {},
        Aliases = {},
        BaseCommandHandlers = {},
        DefaultHandler = nil,
        UnknownHandler = nil,
    }, Router)

    if options and options.baseCommands then
        for _, cmd in ipairs(options.baseCommands) do
            t:RegisterBaseCommand(cmd)
        end
    end

    return t
end

---@param command string
function Router:RegisterBaseCommand(command)
    if not command then return end
    table.insert(self.BaseCommands, command)
    LibRu.RegisterSlashCommand(command, function(msg, editbox)
        self:DispatchBase(command, msg, editbox)
    end)
end

---@param command string
function Router:AddRootCommand(command)
    self:RegisterBaseCommand(command)
end

---@param commands string[]
function Router:AddRootCommands(commands)
    if not commands then return end
    for _, command in ipairs(commands) do
        self:RegisterBaseCommand(command)
    end
end

---@param command string
---@param handler function
---@param options? {always?: boolean}
function Router:RegisterRootCommand(command, handler, options)
    if not command or not handler then return end
    self:RegisterBaseCommand(command)
    self.BaseCommandHandlers[command:lower()] = {
        handler = handler,
        always = options and options.always or false,
    }
end

---@param handler function
function Router:SetDefault(handler)
    self.DefaultHandler = handler
end

---@param handler function
function Router:SetUnknown(handler)
    self.UnknownHandler = handler
end

local function EnsurePath(root, segments)
    local node = root
    for _, segment in ipairs(segments) do
        node.children = node.children or {}
        node.children[segment] = node.children[segment] or {}
        node = node.children[segment]
    end
    return node
end

local function SplitPath(path)
    local segments = {}
    for part in string.gmatch(path, "[^%s]+") do
        table.insert(segments, part:lower())
    end
    return segments
end

---@param name string
---@param handler function
---@param options? {aliases?: string[], help?: string, usage?: string}
function Router:RegisterSubcommand(name, handler, options)
    self:RegisterCommand(name, handler, options)
end

---@param path string
---@param handler function
---@param options? {aliases?: string[], help?: string, usage?: string}
function Router:RegisterCommand(path, handler, options)
    if not path or not handler then return end
    local segments = SplitPath(path)
    if #segments == 0 then return end

    local node = EnsurePath(self.Subcommands, segments)
    node.handler = handler
    node.help = options and options.help or nil
    node.usage = options and options.usage or nil

    if options and options.aliases then
        for _, alias in ipairs(options.aliases) do
            self.Aliases[alias:lower()] = table.concat(segments, " ")
        end
    end
end

---@param baseCommand string
---@param msg string
---@param editbox? EditBox
function Router:DispatchBase(baseCommand, msg, editbox)
    local baseKey = (baseCommand or ""):lower()
    local input = Trim(msg or "")
    local entry = self.BaseCommandHandlers[baseKey]
    if entry and entry.handler then
        local context = {
            router = self,
            baseCommand = baseCommand,
            command = "",
            args = ParseArgs(input),
            rest = input,
            raw = msg or "",
            editbox = editbox,
        }

        if entry.always then
            return entry.handler(context)
        end

        if input == "" then
            return entry.handler(context)
        end
    end

    return self:Dispatch(msg, editbox, baseCommand)
end

---@param msg string
---@param editbox? EditBox
function Router:Dispatch(msg, editbox, baseCommand)
    local input = Trim(msg or "")
    if input == "" then
        if self.DefaultHandler then
            return self.DefaultHandler({
                router = self,
                baseCommand = baseCommand,
                command = "",
                args = {},
                rest = "",
                raw = msg or "",
                editbox = editbox,
            })
        end
        return
    end

    local tokens = ParseArgs(input)
    local first = tokens[1]
    if not first then return end

    local aliasPath = self.Aliases[first:lower()]
    if aliasPath then
        local aliasSegments = SplitPath(aliasPath)
        table.remove(tokens, 1)
        for i = #aliasSegments, 1, -1 do
            table.insert(tokens, 1, aliasSegments[i])
        end
    end

    local node = self.Subcommands
    local matched = {}
    local index = 1
    while tokens[index] do
        local key = tokens[index]:lower()
        if not node.children or not node.children[key] then
            break
        end
        node = node.children[key]
        table.insert(matched, key)
        index = index + 1
    end

    local args = {}
    for i = index, #tokens do
        table.insert(args, tokens[i])
    end

    local context = {
        router = self,
        baseCommand = baseCommand,
        command = table.concat(matched, " "),
        args = args,
        rest = table.concat(args, " "),
        raw = msg or "",
        editbox = editbox,
    }

    if node and node.handler and #matched > 0 then
        return node.handler(context)
    end

    if self.UnknownHandler then
        return self.UnknownHandler(context)
    end

    if self.DefaultHandler then
        return self.DefaultHandler(context)
    end
end