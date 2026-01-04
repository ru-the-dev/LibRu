-- Factory:
--   local MyDB = NewDatabase("SavedVariableName", DefaultsTable)
--   MyDB:Init()  -- once on ADDON_LOADED
--   MyDB:Get()
--   MyDB:ResetAll()
--   MyDB:ResetSection({ "TransmogFrame" })
--   MyDB:ResetValue({ "TransmogFrame", "SetFrameModels" })

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

function NewDatabase(svName, defaults)
    local API = {}
    local initialized = false

    function API:Init()
        if initialized then return _G[svName] end
        _G[svName] = _G[svName] or {}
        copyDefaults(_G[svName], defaults)
        initialized = true
        setmetatable(_G[svName], { __index = API })
        return _G[svName]
    end

    function API:Get()
        return _G[svName] or self:Init()
    end

    function API:ResetAll()
        _G[svName] = {}
        copyDefaults(_G[svName], defaults)
        setmetatable(_G[svName], { __index = API })
        return _G[svName]
    end

    -- path: {"Section","Key",...}
    function API:ResetValue(path)
        local db = self:Get()
        local defs = defaults
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

    -- path: {"Section"} or deeper
    function API:ResetSection(path)
        local db = self:Get()
        local defs = defaults
        for i = 1, #path do
            defs = defs and defs[path[i]]
        end
        local parent, key = walkToParent(db, path)
        parent[key] = {}
        if defs then copyDefaults(parent[key], defs) end
        return parent[key]
    end

    return API
end