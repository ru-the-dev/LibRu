-- create library
if _G.LibManager == nil then
    error("LibManager is required To Initialize LibRu. Please ensure LibManager.lua is loaded before LibRu.lua")
end

---@class LibRu
local LibRu = _G.LibManager.NewLibrary("LibRu", 1, 5);