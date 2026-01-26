local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu


---@class LibRu.Frames.Mixin.ChangeLogFrameMixin
local ChangeLogFrameMixin = {}

---@class LibRu.Frames.Mixin.ChangeLogFrameMixin.ChangeLogStyle
---@field normalTextSize number Font size for normal text (default: 12)
---@field heading1TextSize number Font size for level 1 headings (default: 16)
---@field heading2TextSize number Font size for level 2 headings (default: 14)
---@field heading3TextSize number Font size for level 3 headings (default: 14)
---@field headingColor string Hex color for headings (default: 'ffd100')
---@field textColor string Hex color for text (default: 'ffffff')

-- Default font size constants
local DEFAULT_NORMAL_TEXT_SIZE = 12
local DEFAULT_HEADING1_TEXT_SIZE = 16
local DEFAULT_HEADING2_TEXT_SIZE = 14
local DEFAULT_HEADING3_TEXT_SIZE = 14

-- Default color constants
local DEFAULT_HEADING_COLOR = 'ffd100'
local DEFAULT_TEXT_COLOR = 'ffffff'

--- Initialize the changelog frame
---@param addonName string
---@param logoPath string
---@param style? LibRu.Frames.Mixin.ChangeLogFrameMixin.ChangeLogStyle Optional styling configuration
function ChangeLogFrameMixin:Initialize(addonName, logoPath, style)
    style = style or {}
    
    -- empty version table, filled by SetChangeLogData
    self.Versions = {}

    -- Set styling constants (use defaults if not provided)
    self.normalTextSize = style.normalTextSize or DEFAULT_NORMAL_TEXT_SIZE
    self.heading1TextSize = style.heading1TextSize or DEFAULT_HEADING1_TEXT_SIZE
    self.heading2TextSize = style.heading2TextSize or DEFAULT_HEADING2_TEXT_SIZE
    self.heading3TextSize = style.heading3TextSize or DEFAULT_HEADING3_TEXT_SIZE
    self.headingColor = style.headingColor or DEFAULT_HEADING_COLOR
    self.textColor = style.textColor or DEFAULT_TEXT_COLOR

    -- Set title and portrait if containers exist (PortraitFrameTemplate provides these)
    if self.TitleContainer and self.TitleContainer.TitleText then
        self.TitleContainer.TitleText:SetText(addonName .. " Changelog")
    end
    if self.PortraitContainer and self.PortraitContainer.portrait then
        self.PortraitContainer.portrait:SetTexture(logoPath)
    end

    -- Make draggable
    if LibRu and LibRu.Utils and LibRu.Utils.Frame and self.TitleContainer then
        LibRu.Utils.Frame.MakeDraggable(self.TitleContainer, self)
    end

    -- Add resize button
    if LibRu and LibRu.Frames and LibRu.Frames.ResizeButton then
        local resizeButton = LibRu.Frames.ResizeButton.New(self, self, 30)
        resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")
        self.BT_ResizeButton = resizeButton
    end

    self.changelogData = {}
    self.versionButtons = {}

    -- Set up scroll child dimensions
    local leftScrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "LeftFrame.ScrollFrame")
    local leftScrollChild = LibRu.Utils.Frame.GetFrameByPath(leftScrollFrame, "ScrollChild")
    if leftScrollFrame and leftScrollChild then
        leftScrollChild:SetWidth(leftScrollFrame:GetWidth())
        leftScrollChild:SetHeight(leftScrollFrame:GetHeight()) -- Start with full height
    end
    
    --- hide right scroll bar
    leftScrollFrame.ScrollBar:Hide()

    local rightScrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "RightFrame.ScrollFrame")
    -- Reposition scrollbar for right frame
    if rightScrollFrame then
        rightScrollFrame.ScrollBar:ClearAllPoints()
        rightScrollFrame.ScrollBar:SetPoint("TOPLEFT", rightScrollFrame, "TOPRIGHT", 6, -5)
        rightScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", rightScrollFrame, "BOTTOMRIGHT", 6, 5)
    end

    -- Set up resize handler
    self:SetScript("OnSizeChanged", self.OnSizeChanged)
end





--- Set the changelog data and initialize version buttons sorted from new to old
---@param changelogData table
function ChangeLogFrameMixin:SetChangeLogData(changelogData)
    local scrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "LeftFrame.ScrollFrame")
    local scrollChild = LibRu.Utils.Frame.GetFrameByPath(scrollFrame, "ScrollChild")

    if not scrollFrame or not scrollChild then
        error("LeftFrame.ScrollFrame.ScrollChild not found")
        return
    end

    self.changelogData = changelogData

    self:SortVersions()
    self:ClearVersionButtons();
    self:CreateVersionButtons();
end

function ChangeLogFrameMixin:SortVersions()
    self.Versions = {}

    -- Helper function to parse version string
    local function parseVersion(v)
        local major, minor, patch = v:match("Version (%d+)%.(%d+)%.(%d+)")
        return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
    end

    -- Get and sort versions from new to old
    for v in pairs(self.changelogData) do
        table.insert(self.Versions, v)
    end

    table.sort(self.Versions, function(a, b)
        local am, amin, ap = parseVersion(a)
        local bm, bmin, bp = parseVersion(b)
        if am ~= bm then return am > bm end
        if amin ~= bmin then return amin > bmin end
        return ap > bp
    end)
end

function ChangeLogFrameMixin:ClearVersionButtons()
    -- Clear existing buttons
    for _, button in ipairs(self.versionButtons) do
        button:Hide()
        button:SetParent(nil)
    end
    self.versionButtons = {}
end

function ChangeLogFrameMixin:CreateVersionButtons()
    local scrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "LeftFrame.ScrollFrame")
    local scrollChild = LibRu.Utils.Frame.GetFrameByPath(scrollFrame, "ScrollChild")

    if not scrollFrame or not scrollChild then
        error("LeftFrame.ScrollFrame.ScrollChild not found")
        return
    end

    for i, version in ipairs(self.Versions) do
        local button = CreateFrame("Button", nil, scrollChild, "LibRu_ChangeLogButtonTemplate")
        local yOffset = -5

        if i > 1 then
            local lastButton = self.versionButtons[i-1]
            button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, yOffset)
            button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, yOffset)
        else
            button:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yOffset)
            button:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, yOffset)
        end

        button:GetFontString():SetText(version)
        button:SetScript("OnClick", function()
            self:ShowVersion(version)
        end)

        table.insert(self.versionButtons, button)
    end

    -- Update scroll child height
    if #self.versionButtons > 0 then
        local lastButton = self.versionButtons[#self.versionButtons]
        local buttonBottom = lastButton:GetBottom()
        local scrollFrameTop = scrollFrame:GetTop()
        local neededHeight = scrollFrameTop - buttonBottom + 10
        scrollChild:SetHeight(neededHeight)
    end
end

--- Show the content for a specific version
---@param version? string Optional version to show changelog for, defaults to latest
function ChangeLogFrameMixin:ShowVersion(version)
    if #self.Versions == 0 then return end;

    local scrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "RightFrame.ScrollFrame")
    ---@type LibRu.Frames.Mixin.ChangeLogElementMixin|Frame|nil
    local scrollChild = LibRu.Utils.Frame.GetFrameByPath(scrollFrame, "ScrollChild")
    if not scrollFrame or not scrollChild then return end
    
    version = version or self.Versions[1]
    
    scrollChild:Clear()

    local elements = self.changelogData[version]
    if not elements then return end

    for _, element in ipairs(elements) do
        local level = element.indent_level or 0
        local parent = scrollChild

        if element.type == 'heading' then
            local template = (element.level == 1) and "LibRu_ChangeLogVersionTemplate" or "LibRu_ChangeLogHeadingTemplate"
            local frame = CreateFrame("Frame", nil, scrollChild, template)
            frame.elementType = element.type
            frame.level = element.level

            frame:SetWidth(parent:GetWidth())
            if frame.text then
                frame.text:SetWidth(frame:GetWidth())
            end
            frame:SetContent(element.text, (element.level == 1) and self.heading1TextSize or (element.level == 2) and self.heading2TextSize or self.heading3TextSize, self.headingColor)
            if element.level == 1 then
                frame:SetUnderline()
            end
            local xOff = level == 0 and 10 or level * 20
            parent:AddChild(frame, xOff)
        elseif element.type == 'text' or element.type == 'list_item' then
            local frame = CreateFrame("Frame", nil, scrollChild, "LibRu_ChangeLogTextTemplate")
            frame.elementType = element.type
            frame:SetWidth(parent:GetWidth())
            if frame.text then
                frame.text:SetWidth(frame:GetWidth())
            end
            frame:SetContent(element.text, self.normalTextSize, self.textColor)
            local xOff = level == 0 and 10 or level * 20
            parent:AddChild(frame, xOff)
        elseif element.type == 'image' then
            local frame = CreateFrame("Frame", nil, scrollChild, "LibRu_ChangeLogImageTemplate")
            frame.elementType = element.type
            frame:SetImage(element.path)
            local xOff = level == 0 and 10 or level * 20
            parent:AddChild(frame, xOff)
        end
    end

    scrollChild:UpdateLayout()

    if (self.Show) then
        self:Show()
    end
end

--- Handle frame resize
---@param width number
---@param height number
function ChangeLogFrameMixin:OnSizeChanged(width, height)
    local scrollFrame = LibRu.Utils.Frame.GetFrameByPath(self, "RightFrame.ScrollFrame")
    ---@type LibRu.Frames.Mixin.ChangeLogElementMixin|Frame|nil
    local scrollChild = LibRu.Utils.Frame.GetFrameByPath(scrollFrame, "ScrollChild")
    if not scrollFrame or not scrollChild then return end

    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:UpdateLayout()
end

-- Ensure LibRu namespace exists
if not LibRu.Frames then LibRu.Frames = {} end
if not LibRu.Frames.Mixins then LibRu.Frames.Mixins = {} end

-- Assign mixins to LibRu namespace
LibRu.Frames.Mixins.ChangeLogFrameMixin = ChangeLogFrameMixin

-- Create global reference for XML compatibility (points to namespaced version)
_G.LibRu_ChangeLogFrameMixin = LibRu.Frames.Mixins.ChangeLogFrameMixin; 
