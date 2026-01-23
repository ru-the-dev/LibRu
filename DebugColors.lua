---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize Debug")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

-- Debug color queue (hex RRGGBB strings). Modules will be assigned colors round-robin.
LibRu.DebugColors = LibRu.DebugColors or {
    "ffd166", -- warm yellow
    "06d6a0", -- teal
    "118ab2", -- blue
    "073b4c", -- dark teal
    "ef476f", -- pink/red
    "8a2be2", -- purple
    "00ff7f", -- spring green
}
LibRu._nextDebugColorIndex = LibRu._nextDebugColorIndex or 1