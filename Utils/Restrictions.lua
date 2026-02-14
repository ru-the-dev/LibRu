local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

LibRu.Utils = LibRu.Utils or {};


---@class LibRu.Utils.Restrictions
---@field private _restrictions Enum.AddOnRestrictionType[]
---@field private _restrictionSet table<Enum.AddOnRestrictionType, boolean>
local Restrictions = {}
LibRu.Utils.Restrictions = Restrictions

---@param ... Enum.AddOnRestrictionType
function Restrictions.New(...)
    local self = setmetatable({}, { __index = Restrictions })
    
    self._restrictions = { ... }

    -- build a quick-lookup set to avoid O(n^2) contains checks
    self._restrictionSet = {}
    for _, v in ipairs(self._restrictions) do
        self._restrictionSet[v] = true
    end

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

---@param ... Enum.AddOnRestrictionType
---@return boolean
function Restrictions:Contains(...)
    local restrictionsToCheck = { ... }
    
    for _, restriction in ipairs(restrictionsToCheck) do
        if self._restrictionSet[restriction] then
            return true
        end
    end

    return false
end