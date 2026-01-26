local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

LibRu.Utils = LibRu.Utils or {};

local UrlClicker = {}
LibRu.Utils.UrlClicker = UrlClicker;


local UrlFrame = nil

local function CreateCopyUrlFrame()
    if UrlFrame then return end

    UrlFrame = CreateFrame("Frame", "LibRu_UrlClickerFrame", UIParent, "BasicFrameTemplateWithInset")
    UrlFrame:SetSize(400, 120)
    UrlFrame:SetPoint("CENTER")
    UrlFrame:SetMovable(true)
    UrlFrame:EnableMouse(true)
    UrlFrame:RegisterForDrag("LeftButton")
    UrlFrame:SetScript("OnDragStart", UrlFrame.StartMoving)
    UrlFrame:SetScript("OnDragStop", UrlFrame.StopMovingOrSizing)

    UrlFrame.title = UrlFrame:CreateFontString(nil, "OVERLAY")
    UrlFrame.title:SetFontObject("GameFontHighlight")
    UrlFrame.title:SetPoint("LEFT", UrlFrame.TitleBg, "LEFT", 5, 0)
    UrlFrame.title:SetText("Copy URL")

    local editBox = CreateFrame("EditBox", nil, UrlFrame, "InputBoxTemplate")
    editBox:SetSize(360, 30)
    editBox:SetPoint("TOP", UrlFrame, "TOP", 0, -40)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function(self) UrlFrame:Hide() end)

    UrlFrame.editBox = editBox
end

function UrlClicker.OpenCopyUrlFrame(url)
    CreateCopyUrlFrame()
    
    if (UrlFrame == nil) then return end

    UrlFrame.editBox:SetText(url)
    UrlFrame.editBox:HighlightText()
    UrlFrame:Show()
end

