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
    UrlFrame:SetFrameStrata("FULLSCREEN_DIALOG")

    UrlFrame.title = UrlFrame:CreateFontString(nil, "OVERLAY")
    UrlFrame.title:SetFontObject("GameFontHighlight")
    UrlFrame.title:SetPoint("LEFT", UrlFrame.TitleBg, "LEFT", 5, 0)
    UrlFrame.title:SetText("Copy URL")

    UrlFrame.message = UrlFrame:CreateFontString(nil, "OVERLAY")
    UrlFrame.message:SetFontObject("GameFontNormalOutline")
    UrlFrame.message:SetPoint("TOPLEFT", UrlFrame, "TOPLEFT", 10, -20)
    UrlFrame.message:SetPoint("BOTTOMRIGHT", UrlFrame, "BOTTOMRIGHT", -10, 40)
    UrlFrame.message:SetText("")

    
    local editBox = CreateFrame("EditBox", nil, UrlFrame, "InputBoxTemplate")
    editBox:SetSize(360, 30)
    editBox:SetPoint("BOTTOM", UrlFrame, "BOTTOM", 0, 10)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function(self) UrlFrame:Hide() end)

    UrlFrame.copyLabel = UrlFrame:CreateFontString(nil, "OVERLAY")
    UrlFrame.copyLabel:SetFontObject("GameFontHighlight")
    UrlFrame.copyLabel:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -5, -5)
    UrlFrame.copyLabel:SetText("Ctrl+C to copy the URL below:")

    UrlFrame.editBox = editBox
end

---comment
---@param url string url to open
---@param message? string optional message to display above the url
function UrlClicker.OpenCopyUrlFrame(url, message)
    CreateCopyUrlFrame()
    
    if (UrlFrame == nil) then return end

    UrlFrame.message:SetText(message or "")

    UrlFrame.editBox:SetText(url)
    UrlFrame.editBox:HighlightText()
    UrlFrame:Show()
end

