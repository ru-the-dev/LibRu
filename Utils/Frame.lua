local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

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

--- Retrieves a frame by its nested path
--- @param frame Frame The root frame to start the search from
--- @param path? string The dot-separated path to the target frame (e.g., "ChildFrame.SubFrame.TargetFrame")
--- @return Frame|nil The target frame if found, or nil if any part of the path is invalid
function FrameUtils.GetFrameByPath(frame, path)
    if not path or path == "" then
        return frame;
    end

    local currentFrame = frame;
    for segment in string.gmatch(path, "[^%.]+") do
        currentFrame = currentFrame[segment];
        if not currentFrame then
            return nil;
        end
    end
    
    return currentFrame;
end

