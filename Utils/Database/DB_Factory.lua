local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu
LibRu.Utils = LibRu.Utils or {}

local DB_Utils = {}
LibRu.Utils.DB = DB_Utils

local function copyDefaults(dst, src, seen)
    seen = seen or {}
    if seen[src] then return end
    seen[src] = true

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            copyDefaults(dst[k], v, seen)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

local function walkToParent(root, path)
    local node = root
    for i = 1, #path - 1 do
        local k = path[i]
        node[k] = node[k] or {}
        node = node[k]
    end
    return node, path[#path]
end

---@class LibRu.DatabaseAPI
---@field Init fun(self: LibRu.DatabaseAPI): table
---@field Get fun(self: LibRu.DatabaseAPI): table
---@field ResetAll fun(self: LibRu.DatabaseAPI): table
---@field ResetValue fun(self: LibRu.DatabaseAPI, path: string[]): any
---@field ResetSection fun(self: LibRu.DatabaseAPI, path: string[]): table

---Creates a database API that exposes data only via :Get()
---@generic T
---@param svName string
---@param defaults T
---@return LibRu.DatabaseAPI
function DB_Utils.CreateDatabase(svName, defaults)
    local db = {}
    local data = {}
    local initialized = false

    local function ensure()
        if initialized and data then
            return data
        end
        local sv = _G[svName] or {}
        _G[svName] = sv
        copyDefaults(sv, defaults)
        data = sv
        initialized = true
        return data
    end

    function db:Init()
        return ensure()
    end

    function db:Get()
        return ensure()
    end

    function db:ResetAll()
        _G[svName] = {}
        data = _G[svName]
        copyDefaults(data, defaults)
        initialized = true
        return data
    end

    function db:ResetValue(path)
        local dbData = self:Get()
        local defs = defaults
        for i = 1, #path - 1 do
            defs = defs and defs[path[i]]
        end
        local parent, key = walkToParent(dbData, path)
        local defVal = defs and defs[key]
        if type(defVal) == "table" then
            parent[key] = {}
            copyDefaults(parent[key], defVal)
        elseif defVal ~= nil then
            parent[key] = defVal
        else
            parent[key] = nil
        end
        return parent[key]
    end

    function db:ResetSection(path)
        local dbData = self:Get()
        local defs = defaults
        for i = 1, #path do
            defs = defs and defs[path[i]]
        end
        local parent, key = walkToParent(dbData, path)
        parent[key] = {}
        if defs then copyDefaults(parent[key], defs) end
        return parent[key]
    end

    return db
end