local addon, ns = ...
if ns.LibRu == nil then return end

---@class LibRu
local LibRu = ns.LibRu

--- EventFrame class for managing event handlers and scripts on a frame
--- Handles WoW game events (auto-fired by game) and scripts (frame scripts + custom callbacks)
--- @class LibRu.Frames.EventFrame : ScriptRegion
--- @field private _eventHandlers table<string, {callback: function, handle: number, removed: boolean}[]>
--- @field private _scriptHandlers table<string, {callback: function, handle: number, removed: boolean}[]>
--- @field private _nextEventHandle number
--- @field private _isDispatching boolean
local EventFrame = {}

--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param frame T
--- @return T|LibRu.Frames.EventFrame The frame with EventFrame functionality mixed in
function EventFrame.New(frame)
    -- Capture all existing Frame scripts before converting to EventFrame
    local originalScripts = {}
    
    -- All possible Frame scripts from WoW API
    -- see: https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetScript
    local frameScripts = {
        "OnAttributeChanged", "OnChar", "OnDisable", "OnDragStart", "OnDragStop",
        "OnEnable", "OnEvent", "OnGamePadButtonDown", "OnGamePadButtonUp", "OnGamePadStick",
        "OnHyperlinkClick", "OnHyperlinkEnter", "OnHyperlinkLeave", "OnKeyDown", "OnKeyUp",
        "OnReceiveDrag", "OnSizeChanged", "OnUpdate",
        -- ScriptRegion scripts
        "OnShow", "OnHide", "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp", "OnMouseWheel",
        "OnLoad",
        -- Button scripts
        "OnClick", "OnDoubleClick", "PostClick", "PreClick",
        -- Model/DressUpModel scripts
        "OnAnimFinished", "OnAnimStarted", "OnModelLoaded", "OnDressModel",
        -- EditBox scripts
        "OnArrowPressed", "OnCharComposition", "OnCursorChanged", "OnEditFocusGained",
        "OnEditFocusLost", "OnEnterPressed", "OnEscapePressed", "OnSpacePressed",
        "OnInputLanguageChanged", "OnTabPressed", "OnTextChanged", "OnTextSet",
        -- ScrollFrame scripts
        "OnHorizontalScroll", "OnScrollRangeChanged", "OnVerticalScroll",
        -- Slider/StatusBar scripts
        "OnMinMaxChanged", "OnValueChanged",
        -- Tooltip scripts
        "OnTooltipCleared", "OnTooltipSetDefaultAnchor", "OnTooltipSetFramestack",
        "OnTooltipAddMoney", "OnTooltipSetAchievement", "OnTooltipSetEquipmentSet",
        "OnTooltipSetItem", "OnTooltipSetQuest", "OnTooltipSetSpell", "OnTooltipSetUnit",
        -- ColorSelect
        "OnColorSelect",
        -- Cooldown
        "OnCooldownDone",
        -- MovieFrame
        "OnMovieFinished",
        -- FogOfWarFrame
        "OnUiMapChanged"
    }
    
    -- Store any scripts that exist on this frame (safely check with pcall)
    for _, scriptType in ipairs(frameScripts) do
        local success, script = pcall(function() return frame:GetScript(scriptType) end)
        if success and script then
            originalScripts[scriptType] = script
        end
    end
    
    local self = frame or CreateFrame("Frame")
    self = Mixin(self, EventFrame)
    self._eventHandlers = {}
    self._scriptHandlers = {}
    self._nextEventHandle = 0
    self._isDispatching = false
    
    self:SetScript("OnEvent", function(self, event, ...)
        local handlers = self._eventHandlers[event]
        if not handlers then return end
        
        self._isDispatching = true
        local hasRemovals = false
        
        -- Execute all non-removed handlers
        for _, entry in ipairs(handlers) do
            if entry.removed then
                hasRemovals = true
            else
                entry.callback(self, entry.handle, event, ...)
            end
        end
        
        self._isDispatching = false
        
        -- Clean up removed handlers if any
        if hasRemovals then
            for i = #handlers, 1, -1 do
                if handlers[i].removed then
                    table.remove(handlers, i)
                end
            end
            
            if #handlers == 0 then
                self:UnregisterEvent(event)
                self._eventHandlers[event] = nil
            end
        end
    end)
    
    -- Re-apply all original scripts after conversion
    for scriptType, originalScript in pairs(originalScripts) do
        frame:SetScript(scriptType, originalScript)
    end
    
    return frame
end

--- Adds an event handler callback to the frame for a WoW game event.
--- Game events are automatically registered with WoW and fired by the game engine.
--- For custom callbacks, use AddScript() instead.
--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param self T The EventFrame instance.
--- @param event string The name of the WoW game event to listen for (e.g., "PLAYER_LOGIN", "ADDON_LOADED").
--- @param callback fun(self: T, handle: number, event: string, ...: any) The function to call when the event is triggered. 
--- @return number A unique handle for the registered event handler, which can be used for removal.
--- @error Throws an error if the callback is not a function.
function EventFrame:AddEvent(event, callback)
    -- Validate parameters
    if type(callback) ~= "function" then error("Callback must be a function") end

    -- Initialize the event handler list for this event if it doesn't exist
    self._eventHandlers[event] = self._eventHandlers[event] or {}

    -- Generate a unique handle for this event handler
    self._nextEventHandle = self._nextEventHandle + 1
    local handle = self._nextEventHandle

    -- Store the callback and handle
    table.insert(self._eventHandlers[event], {callback = callback, handle = handle, removed = false})

    -- If this is the first handler for the event, register it with WoW
    if #self._eventHandlers[event] == 1 then
        self:RegisterEvent(event)
    end

    return handle
end

--- Removes an event handler by handle.
--- During event dispatch: marks handler for removal (cleaned up after callbacks complete)
--- Outside dispatch: removes handler immediately
--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param self T
--- @param handle number The unique handle identifying the event handler to remove.
--- @return boolean Returns true if handler was found, false otherwise.
function EventFrame:RemoveEvent(handle)
    for event, handlers in pairs(self._eventHandlers) do
        for index, entry in ipairs(handlers) do
            if entry.handle == handle then
                if self._isDispatching then
                    -- Defer removal until after current dispatch completes
                    entry.removed = true
                else
                    -- Remove immediately
                    table.remove(handlers, index)
                    if #handlers == 0 then
                        pcall(function() self:UnregisterEvent(event) end)
                        self._eventHandlers[event] = nil
                    end
                end
                return true
            end
        end
    end
    return false
end



--- Adds a handler for a frame script or custom callback.
--- Works for both WoW frame scripts (OnShow, OnHide, OnUpdate, etc.) and custom callbacks.
--- For frame scripts: preserves any existing script behavior and adds the new handler.
--- For custom callbacks: use FireScript() to manually trigger them.
--- Multiple handlers can be added for the same script type.
--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param self T
--- @param scriptType string The script type (e.g., "OnShow", "OnHide", "OnUpdate") or custom name (e.g., "BT_TRANSMOG_UPDATED").
--- @param callback fun(self: T, handle: number, ...: any) The function to call when the script fires.
--- @return number A unique handle for the script handler, which can be used for removal.
function EventFrame:AddScript(scriptType, callback)
    if type(callback) ~= "function" then error("Callback must be a function") end
    
    -- Initialize script handler storage
    self._scriptHandlers = self._scriptHandlers or {}
    self._scriptHandlers[scriptType] = self._scriptHandlers[scriptType] or {}
    
    -- Generate unique handle
    self._nextEventHandle = self._nextEventHandle + 1
    local handle = self._nextEventHandle
    
    -- Store the callback
    table.insert(self._scriptHandlers[scriptType], {
        callback = callback,
        handle = handle,
        removed = false
    })
    
    -- If this is the first handler, set up the base script
    if #self._scriptHandlers[scriptType] == 1 then
        -- Preserve existing script if it exists (only works for valid WoW frame scripts)
        local existingScript = nil
        local success
        success, existingScript = pcall(function() return self:GetScript(scriptType) end)
        if not success then existingScript = nil end
        
        -- For custom scripts, don't use SetScript (it will error)
        -- Just store handlers and rely on FireScript to trigger them
        local isCustomScript = not pcall(function() self:SetScript(scriptType, function() end) end)
        
        if not isCustomScript then
            self:SetScript(scriptType, function(self, ...)
            -- Call the original script first (if it existed)
            if existingScript then
                existingScript(self, ...)
            end
            
            -- Then call all our handlers
            local handlers = self._scriptHandlers[scriptType]
            if not handlers then return end
            
            local hasRemovals = false
            
            for _, entry in ipairs(handlers) do
                if entry.removed then
                    hasRemovals = true
                else
                    entry.callback(self, entry.handle, ...)
                end
            end
            
            -- Clean up removed handlers
            if hasRemovals then
                for i = #handlers, 1, -1 do
                    if handlers[i].removed then
                        table.remove(handlers, i)
                    end
                end
                
                -- If no handlers left, restore original script or clear it
                if #handlers == 0 then
                    self:SetScript(scriptType, existingScript)
                    self._scriptHandlers[scriptType] = nil
                end
            end
            end)
        end
    end
    
    return handle
end

--- Manually fires a script to all registered handlers.
--- Use this to trigger custom callbacks. Do not use for WoW frame scripts (they fire automatically).
--- Handlers can safely remove themselves during script execution.
--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param self T
--- @param scriptType string The script type or custom callback name to fire.
--- @vararg any Arguments to pass to the script handlers.
function EventFrame:FireScript(scriptType, ...)
    local handlers = self._scriptHandlers[scriptType]
    if not handlers then return end
    
    local hasRemovals = false
    
    -- Execute all non-removed handlers
    for _, entry in ipairs(handlers) do
        if entry.removed then
            hasRemovals = true
        else
            entry.callback(self, entry.handle, ...)
        end
    end
    
    -- Clean up removed handlers if any
    if hasRemovals then
        for i = #handlers, 1, -1 do
            if handlers[i].removed then
                table.remove(handlers, i)
            end
        end
        
        -- If no handlers left and no existing script, clean up
        if #handlers == 0 then
            self._scriptHandlers[scriptType] = nil
        end
    end
end

--- Removes a script handler by handle.
--- Creates a new EventFrame by converting an existing frame or creating a new one.
--- @generic T : ScriptRegion
--- @param self T
--- @param handle number The unique handle identifying the script handler to remove.
--- @return boolean Returns true if handler was found, false otherwise.
function EventFrame:RemoveScript(handle)
    if not self._scriptHandlers then return false end
    
    for scriptType, handlers in pairs(self._scriptHandlers) do
        for index, entry in ipairs(handlers) do
            if entry.handle == handle then
                entry.removed = true
                return true
            end
        end
    end
    return false
end

LibRu.Frames = LibRu.Frames or {}
LibRu.Frames.EventFrame = EventFrame