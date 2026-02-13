local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

LibRu.Utils = LibRu.Utils or {};


---@class LibRu.Utils.BitFlag
---@field Flags number The current bitflag value
---@field FlagTable table<string, number> A table of valid flag values
local BitFlag = {}
LibRu.Utils.BitFlag = BitFlag


---@param ... number Initial flag values to set
---@return number The resulting bitflag value
function BitFlag.Create(...)
    return BitFlag.SetFlag(0, ...)
end

function BitFlag.SetFlag(currentFlags, ...)
    return bit.bor(currentFlags, ...)
end

function BitFlag.ClearFlag(currentFlags, ...)
    return bit.band(currentFlags, bit.bxor(...))
end

---@param currentFlags number
---@param flag number
function BitFlag.HasFlag(currentFlags, flag)
    return bit.band(currentFlags, flag) == flag
end