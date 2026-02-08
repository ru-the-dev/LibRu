local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

LibRu.Utils = LibRu.Utils or {}

---@class LibRu.Debug
LibRu.Debug = LibRu.Debug or {}

-- --------------------------------------------
-- Locals
-----------------------------------------------

---@type Frame|nil
local dumpFrame = nil
---@type EditBox|nil
local dumpEditBox = nil

local function EnsureDumpFrame()
    if dumpFrame and dumpEditBox then
        return dumpFrame, dumpEditBox
    end

    dumpFrame = CreateFrame("Frame", "LibRu_DebugDumpFrame", UIParent, "BasicFrameTemplateWithInset")
    dumpFrame:SetSize(700, 450)
    dumpFrame:SetPoint("CENTER")
    dumpFrame:SetMovable(true)
    dumpFrame:EnableMouse(true)
    dumpFrame:RegisterForDrag("LeftButton")
    dumpFrame:SetScript("OnDragStart", dumpFrame.StartMoving)
    dumpFrame:SetScript("OnDragStop", dumpFrame.StopMovingOrSizing)
    dumpFrame:Hide()

    dumpFrame.title = dumpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dumpFrame.title:SetPoint("LEFT", dumpFrame.TitleBg, "LEFT", 8, 0)
    dumpFrame.title:SetText("Dump")

    local scrollFrame = CreateFrame("ScrollFrame", nil, dumpFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", dumpFrame.InsetBg, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", dumpFrame.InsetBg, "BOTTOMRIGHT", -26, 4)

    dumpEditBox = CreateFrame("EditBox", nil, scrollFrame)
    dumpEditBox:SetMultiLine(true)
    dumpEditBox:SetFontObject("ChatFontNormal")
    dumpEditBox:SetAutoFocus(false)
    dumpEditBox:SetWidth(640)
    dumpEditBox:SetText("")

    scrollFrame:SetScrollChild(dumpEditBox)

    return dumpFrame, dumpEditBox
end

local function AppendLine(lines, text)
    lines[#lines + 1] = text
end

local function DumpValue(value, lines, depth, maxDepth, visited, keyName)
    local indent = string.rep("  ", depth)
    local valueType = type(value)

    if keyName ~= nil then
        indent = indent .. tostring(keyName) .. " = "
    end

    if valueType == "table" then
        if visited[value] then
            AppendLine(lines, indent .. "<cycle>")
            return
        end

        if depth >= maxDepth then
            AppendLine(lines, indent .. "<max depth>")
            return
        end

        visited[value] = true
        AppendLine(lines, indent .. "{")
        for k, v in pairs(value) do
            DumpValue(v, lines, depth + 1, maxDepth, visited, k)
        end
        AppendLine(lines, string.rep("  ", depth) .. "}")
        return
    end

    if valueType == "string" then
        AppendLine(lines, indent .. string.format("%q", value))
        return
    end

    AppendLine(lines, indent .. tostring(value))
end

--- Dump any value into a scrollable window.
---@param value any
---@param title? string
---@param maxDepth? number
function LibRu.Debug.DumpToScrollFrame(value, title, maxDepth)
    local frame, editBox = EnsureDumpFrame()
    local lines = {}
    local visited = {}
    local depthLimit = maxDepth or 4

    DumpValue(value, lines, 0, depthLimit, visited, nil)

    frame.title:SetText(title or "Dump")
    editBox:SetText(table.concat(lines, "\n"))
    editBox:HighlightText(0, 0)
    frame:Show()
end
