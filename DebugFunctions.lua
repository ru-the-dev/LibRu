---@class LibRu
local LibRu = _G["LibRu"];

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventDispatcher. Please ensure LibRu is loaded before EventDispatcher.lua")
end

-- LibStub handles version checking, so no need for ShouldLoad check


local DebugFunctions = {};

function DebugFunctions.GetTableAttributeDisplayWidth()
    if TableAttributeDisplay then
        return TableAttributeDisplay:GetWidth()
    end
    return nil
end

function DebugFunctions.GetTableAttributeDisplayHeight()
    if TableAttributeDisplay then
        return TableAttributeDisplay:GetHeight()
    end
    return nil
end

function DebugFunctions.SetTableAttributeDisplayHeight(desiredHeight)
    -- Ensure minimum height
    desiredHeight = math.max(desiredHeight or 300, 150)
    
    print("Setting TableAttributeDisplay height to:", desiredHeight)
    
    -- Define margins for better maintainability
    local FRAME_PADDING = 40        -- Padding for title bar and bottom
    local SCROLL_PADDING = 10       -- Additional padding for scroll area
    
    -- Calculate effective heights
    local scrollFrameHeight = desiredHeight - FRAME_PADDING
    
    -- Set main frame height
    TableAttributeDisplay:SetHeight(desiredHeight)
    
    -- Set scroll frame height
    TableAttributeDisplay.LinesScrollFrame:SetHeight(scrollFrameHeight)
end

function DebugFunctions.SetTableAttributeDisplayWidth(desiredWidth)
    -- Ensure minimum width
    desiredWidth = math.max(desiredWidth or 400, 200)
    
    print("Setting TableAttributeDisplay width to:", desiredWidth)
    
    -- Define margins for better maintainability
    local FRAME_PADDING = 20        -- Padding for the main frame
    local SCROLLBAR_WIDTH = 20      -- Width reserved for scrollbar
    local BUTTON_PADDING = 30       -- Additional padding for buttons/controls
    
    -- Calculate effective widths
    local scrollFrameWidth = desiredWidth - (FRAME_PADDING + SCROLLBAR_WIDTH)
    local contentWidth = scrollFrameWidth - BUTTON_PADDING
    
    -- Set main frame width
    TableAttributeDisplay:SetWidth(desiredWidth)
    
    -- Set scroll frame and container widths
    TableAttributeDisplay.LinesScrollFrame:SetWidth(scrollFrameWidth)
    TableAttributeDisplay.LinesScrollFrame.LinesContainer:SetWidth(scrollFrameWidth)
    
    -- Configure title text
    local titleText = TableAttributeDisplay.TitleButton.Text
    if titleText then
        titleText:SetWidth(contentWidth)
        titleText:SetJustifyH("LEFT")
        titleText:SetWordWrap(false)
        titleText:SetNonSpaceWrap(false)
        titleText:SetMaxLines(1)
        
        -- Enable text truncation with ellipsis
        if titleText.SetMaxLines then
            titleText:SetMaxLines(1)
        end
    end

    -- Update all child elements
    local children = { TableAttributeDisplay.LinesScrollFrame.LinesContainer:GetChildren() }

    for _, child in ipairs(children) do
        -- Update ValueButton text
        if child.ValueButton and child.ValueButton.Text then
            local valueText = child.ValueButton.Text
            valueText:SetWidth(contentWidth)
            valueText:SetJustifyH("LEFT")
            valueText:SetWordWrap(false)
            valueText:SetNonSpaceWrap(false)
            valueText:SetMaxLines(1)
        end
        
        -- Update KeyButton text if it exists
        if child.KeyButton and child.KeyButton.Text then
            local keyText = child.KeyButton.Text
            keyText:SetWidth(contentWidth / 2)  -- Keys typically take less space
            keyText:SetJustifyH("LEFT")
            keyText:SetWordWrap(false)
            keyText:SetNonSpaceWrap(false)
            keyText:SetMaxLines(1)
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