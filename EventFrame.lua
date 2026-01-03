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
--- @field _eventHandlers table<string, {callback: function, handle: number}[]>
--- @field _nextEventHandle number
local EventFrame = {}
EventFrame.__index = EventFrame

--- Creates a new EventFrame instance
--- @param frame Frame Optional WoW frame to attach to. If nil, creates a new Frame.
--- @return EventFrame newFrame new EventFrame instance
function EventFrame.New(frame)
    ---@type EventFrame
    local self = frame or CreateFrame("Frame")
    setmetatable(self, EventFrame)
    self._eventHandlers = {}
    self._nextEventHandle = 0
    return self
end

--- Adds an event handler callback to the frame for a specified event.
--- If this is the first handler for the event, registers the event and sets up the OnEvent script
--- to dispatch to all registered handlers for that event.
--- @param self EventFrame The EventFrame instance.
--- @param event string The name of the event to listen for.
--- @param callback function The function to call when the event is triggered. Must be a function.
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

    -- If this is the first handler for the event, register the event and set the OnEvent script
    if #self._eventHandlers[event] == 1 then
        self:RegisterEvent(event)

        -- Set the OnEvent script to dispatch to all handlers for this event
        self:SetScript("OnEvent", function(self, event, ...)
            local handlers = self._eventHandlers[event]
            if handlers then
                for _, entry in ipairs(handlers) do
                    entry.callback(entry.handle, event, ...)
                end
            end
        end)
    end

    return handle
end

--- Removes an event handler from the frame based on the provided handle.
--- Iterates through all registered events and their handlers, removing the handler that matches the given handle.
--- If the event has no more handlers after removal, it unregisters the event and cleans up the handler list.
--- @param self EventFrame The EventFrame instance.
--- @param handle number The unique handle identifying the event handler to remove.
--- @return boolean Returns true if a handler was removed, false otherwise.
function EventFrame:RemoveEvent(handle)
    -- Iterate over all events and their handlers
    for event, handlers in pairs(self._eventHandlers) do
        -- Iterate backwards to safely remove handlers (avoid index shifting)
        for index = #handlers, 1, -1 do
            if handlers[index].handle == handle then
                -- Remove the handler
                table.remove(handlers, index)
                -- If no handlers remain for this event, unregister it
                if #handlers == 0 then
                    self:UnregisterEvent(event)
                    self._eventHandlers[event] = nil
                end
                return true
            end
        end
    end
    return false
end

LibRu.EventFrame = EventFrame