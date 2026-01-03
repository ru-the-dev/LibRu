---@class LibRu : Library
local LibRu = _G["LibRu"];

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventDispatcher. Please ensure LibRu is loaded before EventDispatcher.lua")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end


local DebugFunctions = {};

function DebugFunctions.SetTableAttributeDisplayWidth(desiredWidth)
    print("Setting TableAttributeDisplay width to:", desiredWidth)
    TableAttributeDisplay:SetWidth(desiredWidth)
    TableAttributeDisplay.LinesScrollFrame:SetWidth(desiredWidth - 70)
    TableAttributeDisplay.LinesScrollFrame.LinesContainer:SetWidth(desiredWidth - 70)
    
    local titleText = TableAttributeDisplay.TitleButton.Text;
    -- Adjust width and alignment
    titleText:SetWidth(desiredWidth - 60)
    titleText:SetJustifyH("LEFT") -- Aligns text properly

    -- Additional fixes
    titleText:SetWordWrap(false) -- Prevents multi-line text
    titleText:SetNonSpaceWrap(false) -- Prevents breaking words mid-character
    titleText:SetMaxLines(1)     -- Forces text to stay on one line

    local children = { TableAttributeDisplay.LinesScrollFrame.LinesContainer:GetChildren() }

    for _, child in ipairs(children) do
        if child.ValueButton and child.ValueButton.Text then -- Ensure it's a valid FontString
            local valueText = child.ValueButton.Text;

            -- Adjust width and alignment
            valueText:SetWidth(desiredWidth - 60)
            valueText:SetJustifyH("LEFT") -- Aligns text properly

            -- Additional fixes
            valueText:SetWordWrap(false) -- Prevents multi-line text
            valueText:SetNonSpaceWrap(false) -- Prevents breaking words mid-character
            valueText:SetMaxLines(1)     -- Forces text to stay on one line
        end
    end
end

function DebugFunctions.TableToString(t, indent, seen)
    indent = indent or 0
    seen = seen or {}
    if type(t) ~= "table" then return tostring(t) end
    if seen[t] then return "<cycle>" end
    seen[t] = true
    local pad = string.rep(" ", indent)
    local parts = {"{\n"}
    for k, v in pairs(t) do
        local key = type(k) == "string" and string.format("%q", k) or tostring(k)
        local val = (type(v) == "table") and DebugFunctions.TableToString(v, indent + 2, seen) or
                    (type(v) == "string" and string.format("%q", v) or tostring(v))
        table.insert(parts, string.format("%s  [%s] = %s,\n", pad, key, val))
    end
    table.insert(parts, pad .. "}")
    return table.concat(parts)
end


LibRu.Debug = DebugFunctions;