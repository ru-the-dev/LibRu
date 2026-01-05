---@class LibRu : Library
local LibRu = _G["LibRu"];

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize ResizeButton. Please ensure LibRu is loaded before ResizeButton.lua")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

-- Initialize the Frames table in LibRu if it doesn't exist
LibRu.Frames = LibRu.Frames or {}

--- @class ResizeButton : EventFrame
--- @field ResizeFrame Frame  -- Frame to be resized
--- @field ResizeAnchor string -- Anchor point for resizing
--- @field Texture Texture  -- Texture for the resize button
local ResizeButton = {}
ResizeButton.__index = ResizeButton

--- Creates a standard resize button and adds it to the parent frame.
--- Sets the resize frame to Resizable and MouseEnabled.
--- @param parent Frame Parent frame for the resize button
--- @param resizeFrame Frame Frame to resize
--- @param size? number Size of button (default: 20)
--- @param resizeAnchor? string Resize Anchor Point (default: "BOTTOMRIGHT")
--- @return ResizeButton resizeButton The created resize button
function ResizeButton.New(parent, resizeFrame, size, resizeAnchor)
    resizeFrame:SetResizable(true)
    resizeFrame:EnableMouse(true)
    
    -- Create the button frame as an EventFrame
    ---@type ResizeButton
    local button = LibRu.Frames.EventFrame.New(CreateFrame("Button", nil, parent))
    
    Mixin(button, ResizeButton) -- Mix in the ResizeButton methods
    
    -- Store properties
    button.ResizeFrame = resizeFrame
    button.ResizeAnchor = resizeAnchor or "BOTTOMRIGHT"
    
    -- Configure button
    button:SetSize(size or 20, size or 20)
    button:SetPoint(button.ResizeAnchor)

    -- Create texture
    button.Texture = button:CreateTexture(nil, "OVERLAY")
    button.Texture:SetTexture("interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    button.Texture:SetAllPoints()

    -- Set up resize scripts
    button:AddScript("OnMouseDown", function(self)
        self.ResizeFrame:StartSizing(self.ResizeAnchor)
    end)

    button:AddScript("OnMouseUp", function(self)
        self.ResizeFrame:StopMovingOrSizing()
    end)

    return button
end

-- Register the ResizeButton class in LibRu.Frames
LibRu.Frames.ResizeButton = ResizeButton