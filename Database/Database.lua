local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu



---@class LibRu.Database
local Database = {};
LibRu.Database = Database;

---@generic T
---@param dataTable table The live table (e.g. MySavedVar or {})
---@param defaults T The template table
---@return LibRu.Database.API|{_data: T}
function Database.Create(dataTable, defaults)
    ---@type LibRu.Database.API
    local instance = setmetatable({}, { __index = Database.API })
    
    -- Cast to any to bypass private field restrictions during setup
    local internal = (instance --[[@as any]])
    internal._data = dataTable
    internal._defaults = defaults
    internal._initialized = false
    
    return instance
end