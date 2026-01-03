---@class LibRu : Library
local LibRu = _G["LibRu"];

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventDispatcher. Please ensure LibRu is loaded before EventDispatcher.lua")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

---Creates a standard resize button and adds it to the parent frame.<br>
---Sets the resize frame to Resizable and MouseEnabled.
---@param parent table Parent frame.
---@param resizeFrame table Frame to resize
---@param size? number Size of button.
---@param resizeAnchor? string Resize Anchor Point.
---@return table resizeButton The Created Button.        
function LibRu.CreateResizeButton(parent, resizeFrame, size, resizeAnchor)
    resizeFrame:SetResizable(true);
    resizeFrame:EnableMouse(true);
    
    local resizeButton = CreateFrame("Button", nil, parent);
    resizeButton:SetSize(size or 20, size or 20);
    resizeButton:SetPoint(resizeAnchor or "BOTTOMRIGHT")

    resizeButton.t_texture = resizeButton:CreateTexture(nil, "OVERLAY");
    resizeButton.t_texture:SetTexture("interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up");
    resizeButton.t_texture:SetAllPoints();

    resizeButton:SetScript("OnMouseDown", function()
        resizeFrame:StartSizing(resizeAnchor or "BOTTOMRIGHT")
    end)

    resizeButton:SetScript("OnMouseUp", function()
        resizeFrame:StopMovingOrSizing()
    end)

    return resizeButton;
end