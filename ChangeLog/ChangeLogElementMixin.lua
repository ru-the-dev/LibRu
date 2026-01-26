local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

---@class LibRu.Frames.Mixin.ChangeLogElementMixin
local ChangeLogElementMixin = {}

--- Add a child frame with optional x offset
---@param child Frame
---@param xOffset number?
function ChangeLogElementMixin:AddChild(child, xOffset)
    if not self.children then
        self.children = {}
    end
    table.insert(self.children, child)
    child:SetParent(self)
    child.xOffset = xOffset or 0
    self:UpdateLayout()
end

--- Update the layout of children
function ChangeLogElementMixin:UpdateLayout()
    local yOffset = -10  -- Add initial top margin
    for _, child in ipairs(self.children or {}) do
        child:SetPoint("TOPLEFT", child.xOffset, yOffset)
        if child.texture then
            -- Images have fixed size set in SetImage
        else
            child:SetWidth(self:GetWidth() - child.xOffset)
            if child.text then
                child.text:SetWidth(child:GetWidth())
                child:SetHeight(child.text:GetHeight())
                if child.underline then
                    child.underline:SetWidth(child.text:GetStringWidth())
                end
            end
        end
        yOffset = yOffset - child:GetHeight() - (child.elementType == 'heading' and 10 or 5)
    end
    self:SetHeight(-yOffset)
end

--- Clear all children recursively
function ChangeLogElementMixin:Clear()
    for _, child in ipairs(self.children or {}) do
        if child.Clear then
            child:Clear()
        end
        child:Hide()
        child:SetParent(nil)
    end
    self.children = {}
end

--- Set the content for text frames
---@param text string
---@param fontSize number?
---@param color string?
function ChangeLogElementMixin:SetContent(text, fontSize, color)
    if self.text then
        local displayText = text
        if self.elementType == 'heading' and self.level and self.level > 1 then
            displayText = "|TInterface\\Buttons\\UI-SpellbookIcon-NextPage-Up:15:15|t " .. displayText
        end
        if color then
            displayText = "|cff" .. color .. displayText .. "|r"
        end
        self.text:SetText(displayText)
        self.text:SetFont(STANDARD_TEXT_FONT, fontSize or 12)
        self.text:SetWordWrap(true)
        self:SetHeight(self.text:GetHeight())
    end
end

--- Set the content for image frames
---@param path string
function ChangeLogElementMixin:SetImage(path)
    if self.texture then
        self.texture:SetTexture(path)

        local awaitLoaded = function()
            if not self.texture:IsObjectLoaded() then
                C_Timer.After(0.05, awaitLoaded)
            else
                local width = self.texture:GetWidth()
                local height = self.texture:GetHeight()
                self:SetSize(width, height)
                self:GetParent():UpdateLayout()
            end
        end

        C_Timer.After(0.05, awaitLoaded)
    end
end

--- Set underline for version frames
function ChangeLogElementMixin:SetUnderline()
    if self.underline and self.text then
        self.underline:SetWidth(self.text:GetStringWidth())
    end
end

-- Ensure LibRu namespace exists
if not LibRu.Frames then LibRu.Frames = {} end
if not LibRu.Frames.Mixins then LibRu.Frames.Mixins = {} end

-- Assign mixins to LibRu namespace
LibRu.Frames.Mixins.ChangeLogElementMixin = ChangeLogElementMixin

-- Create global reference for XML compatibility (points to namespaced version)
_G.LibRu_ChangeLogElementMixin = LibRu.Frames.Mixins.ChangeLogElementMixin; 