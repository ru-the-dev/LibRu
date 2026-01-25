-- create library
local LibStub = _G.LibStub
if not LibStub then
    error("LibStub is required to initialize LibRu. Please ensure LibStub is loaded before LibRu.lua")
end

---@class LibRu
local LibRu = LibStub:NewLibrary("LibRu", 1, 6)
if not LibRu then
    -- A newer version of LibRu is already loaded
    return
end