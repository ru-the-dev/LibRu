local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

LibRu.Utils = LibRu.Utils or {};


---@class LibRu.Utils.Restrictions
---@field private _restrictions Enum.AddOnRestrictionType[]
local Restrictions = {}
LibRu.Utils.Restrictions = Restrictions

---@param ... Enum.AddOnRestrictionType
function Restrictions.New(...)
    local self = setmetatable({}, { __index = Restrictions })
    
    self._restrictions = { ... }
    return self
end


function Restrictions:IsAllActive()
    for _, restriction in ipairs(self._restrictions) do
        if not C_RestrictedActions.IsAddOnRestrictionActive(restriction) then
            return false
        end
    end

    return true
end


function Restrictions:IsAnyActive()
    for _, restriction in ipairs(self._restrictions) do
        if C_RestrictedActions.IsAddOnRestrictionActive(restriction) then
            return true
        end
    end

    return false
end