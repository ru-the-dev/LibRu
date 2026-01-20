---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end


--- @class LibRu.Frames.CollapseExtendCheckButton : CheckButton
--- @field Inverted boolean Wether or not the initial texture is inverted or not
local CollapseExtendCheckButton = {}

LibRu.Frames = LibRu.Frames or {}
LibRu.Frames.CollapseExtendCheckButton = CollapseExtendCheckButton


--- Creates a new FlippingCheckButton
---@param parent Frame The parent frame
---@param name string The name of the button
---@param atlas string The atlas name for textures
---@param size number The size of the button
---@param invert? boolean Whether to invert the flip behavior (checked normal, unchecked flipped; default: false)
---@return LibRu.Frames.CollapseExtendCheckButton|LibRu.Frames.EventFrame The created button
function CollapseExtendCheckButton.New(parent, name, atlas, size, invert)
    local button = CreateFrame("CheckButton", name, parent)
    button = LibRu.Frames.EventFrame.New(button);
    
    button = Mixin(button, CollapseExtendCheckButton)
    
    button:SetSize(size, size)
    
    -- Set atlas textures
    button:SetNormalAtlas(atlas)
    button:SetPushedAtlas(atlas)
    button:SetHighlightAtlas(atlas, "ADD")
    
    -- Store invert flip state
    button.Inverted = invert or false

    -- initial sync 
    button:SyncTextures();
    
    -- Flip the textures when checked (or invert if specified)
    button:AddScript("OnClick", function(self, _)
        button:SyncTextures();
    end)
        
    return button
end

function CollapseExtendCheckButton:SyncTextures()
    local isChecked = self:GetChecked();

    local textures = {
        self:GetNormalTexture(),
        self:GetPushedTexture(),
        self:GetHighlightTexture()
    }

    local shouldFlip = isChecked
    if self.Inverted then
        shouldFlip = not shouldFlip
    end

    if shouldFlip then
        -- flip textures horizontally
        for _, texture in ipairs(textures) do
            if texture then texture:SetTexCoord(1, 0, 0, 1) end 
        end
    else
        -- normal
        for _, texture in ipairs(textures) do
            if texture then texture:SetTexCoord(0, 1, 0, 1) end 
        end
    end
end

function CollapseExtendCheckButton:Toggle()
    self:Click();
end

--- Set the collapsed state explicitly.
--- @param collapsed boolean
function CollapseExtendCheckButton:SetCollapsed(collapsed)
    
    -- dont do anything if the state is already correct
    if (self:GetChecked() == collapsed) then return end;

    self:Toggle();
end