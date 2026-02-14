local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

---@class LibRu.Database
LibRu.Database = LibRu.Database or {}

---@generic T
---@class LibRu.Database.API
---@field private _data T The live data table
---@field private _defaults T
---@field private _initialized boolean
local DB_API = {}
LibRu.Database.API = DB_API; 


local function copyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            copyDefaults(dst[k], v)
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

---@generic T
---@param self LibRu.Database.API|{_data: T}
function DB_API:Init()
    if self._initialized then return end
    
    copyDefaults(self._data, self._defaults)
    self._initialized = true
end

---@generic T
---@param self LibRu.Database.API|{_data: T}
---@return T
function DB_API:Get()
    if self._initialized then return self._data end

    self:Init();
    return self._data
end



---@generic T
---@param self LibRu.Database.API|{_data: T}
function DB_API:ResetAll()
    -- Clear the table keys without losing the reference
    for k in pairs(self._data) do self._data[k] = nil end
    copyDefaults(self._data, self._defaults)
    return self._data
end

---@generic T
---@param self LibRu.Database.API|{_data: T}
function DB_API:ResetValue(path)
    local db = self._data
    local defs = self._defaults
    for i = 1, #path - 1 do
        defs = defs and defs[path[i]]
    end
    local parent, key = walkToParent(db, path)
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

---@generic T
---@param self LibRu.Database.API|{_data: T}
---@param path string[]
function DB_API:ResetSection(path)
    local db = self._data
    local defs = self._defaults
    for i = 1, #path do
        defs = defs and defs[path[i]]
    end
    local parent, key = walkToParent(db, path)
    parent[key] = {}
    if defs then copyDefaults(parent[key], defs) end
    return parent[key]
end