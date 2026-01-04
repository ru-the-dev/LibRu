---@class LibRu
local LibRu = _G["LibRu"]

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventFrame")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

--- EventFrame class for managing event handlers on a frame
--- @class EventFrame : Frame
--- @field private _eventHandlers table<string, {callback: function, handle: number, removed: boolean}[]>
--- @field private _nextEventHandle number
--- @field private _isDispatching boolean
local EventFrame = {}


function EventFrame.New(frame)
    ---@type EventFrame
    local self = frame or CreateFrame("Frame")
    Mixin(self, EventFrame)
    self._eventHandlers = {}
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
                entry.callback(entry.handle, event, ...)
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
    
    return self
end

--- Adds an event handler callback to the frame for a specified event.
--- If this is the first handler for the event, registers the event and sets up the OnEvent script
--- to dispatch to all registered handlers for that event.
--- @param self EventFrame The EventFrame instance.
--- @param event string The name of the event to listen for.
--- Registers a callback function to be triggered when a specific event occurs.
--- @param callback fun(handle: number, event: string, ...: any) The function to call when the event is triggered. 
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
    table.insert(self._eventHandlers[event], {callback = callback, handle = handle})

    -- If this is the first handler for the event, register the event
    if #self._eventHandlers[event] == 1 then
        self:RegisterEvent(event)
    end

    return handle
end

--- Removes an event handler by handle.
--- During event dispatch: marks handler for removal (cleaned up after callbacks complete)
--- Outside dispatch: removes handler immediately
--- @param self EventFrame The EventFrame instance.
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
                        self:UnregisterEvent(event)
                        self._eventHandlers[event] = nil
                    end
                end
                return true
            end
        end
    end
    return false
end

LibRu.EventFrame = EventFrame