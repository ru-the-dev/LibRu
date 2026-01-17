---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end


--- @class LibRu.Frames.CollapseExtendCheckButton
local CollapseExtendCheckButton = {}

LibRu.Frames = LibRu.Frames or {}
LibRu.Frames.CollapseExtendCheckButton = CollapseExtendCheckButton

--- Creates a new FlippingCheckButton
---@param parent Frame The parent frame
---@param name string The name of the button
---@param atlas string The atlas name for textures
---@param size number The size of the button
---@return CheckButton|LibRu.Frames.EventFrame The created button
function CollapseExtendCheckButton.New(parent, name, atlas, size)
    local button = CreateFrame("CheckButton", name, parent)
    button = LibRu.Frames.EventFrame.New(button);

    button:SetSize(size, size)
    
    -- Set atlas textures
    button:SetNormalAtlas(atlas)
    button:SetPushedAtlas(atlas)
    button:SetHighlightAtlas(atlas, "ADD")
    
    -- Flip the textures when checked
    button:AddScript("OnUpdate", function(self, _)
        local isChecked = self:GetChecked();

        local textures = {
            self:GetNormalTexture(),
            self:GetPushedTexture(),
            self:GetHighlightTexture()
        }

        if isChecked then
            -- flip textures
            for _, texture in ipairs(textures) do
                if texture then texture:SetTexCoord(1, 0, 0, 1) end 
            end
        else
            for _, texture in ipairs(textures) do
                if texture then texture:SetTexCoord(0, 1, 1, 0) end
            end
        end
    end)
        
    
    return button
end