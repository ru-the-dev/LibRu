---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

LibRu.Utils = LibRu.Utils or {};

local FrameUtils = {}
LibRu.Utils.Frame = FrameUtils;

---Make a frame draggable by handling left-button drag on `dragFrame`.
---If `targetFrame` is omitted, `dragFrame` will be moved. The target is made movable
---and its clamped-to-screen state is set (defaults to true).
---@param dragFrame LibRu.Frames.EventFrame The frame that receives drag events (required).
---@param targetFrame? Frame The frame to move; defaults to `dragFrame`.
---@param clampToScreen? boolean Whether to clamp the target frame to the screen; defaults to `true`.
function FrameUtils.MakeDraggable(dragFrame, targetFrame, clampToScreen)
    targetFrame = targetFrame or dragFrame;
    
    -- make xmog frame movable
    targetFrame:SetMovable(true);
    targetFrame:SetClampedToScreen(clampToScreen or true)
    dragFrame:SetMouseClickEnabled(true)
    dragFrame:RegisterForDrag("LeftButton")

    local addScriptFunc = dragFrame.AddScript or dragFrame.SetScript;


    addScriptFunc(dragFrame, "OnDragStart", function(self)
        if targetFrame:IsMovable() then
            targetFrame:StartMoving()
        end
    end)

    addScriptFunc(dragFrame, "OnDragStop", function(self)
        targetFrame:StopMovingOrSizing()
    end)
end


