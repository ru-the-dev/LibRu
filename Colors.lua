local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

---@class LibRu.Colors
local Colors = {};
LibRu.Colors = Colors


Colors.All = {
    White = "FFFFFF",
    Red = "FF0000",
    Green = "00FF00",
    Blue = "0000FF",
    Yellow = "FFFF00",
    Cyan = "00FFFF",
    Magenta = "FF00FF",
    Orange = "FFA500",
    Purple = "800080",
    Pink = "FFC0CB",
    Lime = "00FF00",
    Teal = "008080",
    Navy = "000080",
    Maroon = "800000",
    Olive = "808000",
    Silver = "C0C0C0",
    Gray = "808080",
    Black = "000000",
    WarmYellow = "FFD166",
    DarkTeal = "005757",
    SpringGreen = "00FF7F",
    LightSkyBlue = "87CEFA",
    Gold = "FFD700",
    Coral = "FF7F50",
    Crimson = "DC143C",
    Indigo = "4B0082",
    Lavender = "E6E6FA",
    Turquoise = "40E0D0",
    Salmon = "FA8072",
    SeaGreen = "2E8B57",
    DarkBlue = "00008B",
    LightBlue = "ADD8E6",
    MidnightBlue = "191970",
    Sienna = "A0522D",
    Chocolate = "D2691E",
    Tan = "D2B48C",
    Beige = "F5F5DC",
    MintCream = "F5FFFA",
    Honeydew = "F0FFF0",
}

-- Debug color queue (hex RRGGBB strings). Modules will be assigned colors round-robin.
Colors.Debug = {
    Colors.All.WarmYellow, -- warm yellow
    Colors.All.Teal, -- teal
    Colors.All.Blue, -- blue
    Colors.All.DarkTeal, -- dark teal
    Colors.All.Pink, -- pink/red
    Colors.All.Purple, -- purple
    Colors.All.SpringGreen, -- spring green
}

local nextDebugColorIndex = 1;

function Colors.GetNextDebugColor()
    local color = Colors.Debug[nextDebugColorIndex]
    nextDebugColorIndex = (nextDebugColorIndex % #Colors.Debug) + 1
    return color
end




---@param color string Hex color code (RRGGBB)
---@param message string The message to format
---@param reset? boolean Whether to reset the color after the message (default: true)
function Colors.ChatFormat(color, message, reset)
    reset = reset == nil and true or reset;

    return "|cFF" .. color .. message .. (reset and "|r" or "");
end