---@class LibRu : Library
local LibRu = _G["LibRu"];

-- Ensure LibRu is loaded before proceeding
if not LibRu then
    error("LibRu is required to initialize EventDispatcher. Please ensure LibRu is loaded before EventDispatcher.lua")
end

-- Early exit if LibRu.ShouldLoad is false
if LibRu.ShouldLoad == false then return end

-- Initialize the Frames table in LibRu if it doesn't exist
LibRu.Frames = LibRu.Frames or {}

--- @class ValueSlider
--- @field _bindTable table  -- Table to bind the slider value
--- @field _bindKey string   -- Key in the bindTable for the slider value
--- @field _min number       -- Minimum value of the slider
local ValueSlider = {}
ValueSlider.__index = ValueSlider

-- Function to set the text of the value display
local function setValueText(valueText, v, formatValue)
    valueText:SetText(formatValue and formatValue(v) or tostring(v)) -- Set text based on formatValue or default to tostring
end

--- Bound Slider Class
--- @param parent Frame        -- Parent frame for the slider
--- @param name string         -- Name of the slider
--- @param labelText string    -- Text label for the slider
--- @param min number          -- Minimum value for the slider
--- @param max number          -- Maximum value for the slider
--- @param step number         -- Step value for the slider
--- @param bindTable table     -- Table to bind the slider value
--- @param bindKey string      -- Key in the bindTable for the slider value
--- @param formatValue fun(v:number):string|nil -- Optional function to format the slider value
function ValueSlider.New(parent, name, labelText, min, max, step, bindTable, bindKey, formatValue)
    -- Create a new slider frame
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    Mixin(slider, ValueSlider) -- Mix in the Slider methods

    -- Set properties for the slider
    slider._bindTable = bindTable
    slider._bindKey   = bindKey
    slider._min       = min
    slider._format    = formatValue

    -- Configure slider dimensions and values
    slider:SetWidth(300)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Set the label and min/max text for the slider
    local label = _G[slider:GetName() .. "Text"]; if label then label:SetText(labelText) end
    local low   = _G[slider:GetName() .. "Low"];  if low  then low:SetText(tostring(min)) end
    local high  = _G[slider:GetName() .. "High"]; if high then high:SetText(tostring(max)) end

    -- Create a font string to display the current value
    local valueText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valueText:SetPoint("LEFT", label, "RIGHT", 12, 0) -- Position the value text
    valueText:SetJustifyH("LEFT") -- Align text to the left
    slider._valueText = valueText -- Store reference to value text

    -- Set the script to handle value changes
    slider:SetScript("OnValueChanged", function(self, v)
        local iv = math.floor(v + 0.5) -- Round the value to the nearest integer
        self._bindTable[self._bindKey] = iv -- Update the bound table with the new value
        setValueText(self._valueText, iv, self._format) -- Update the displayed value text
    end)
    
    -- Initialize the slider's value from the binding
    slider:SetValue(bindTable[bindKey] or min)
    setValueText(slider._valueText, bindTable[bindKey] or min, slider._format)

    return slider -- Return the created slider
end

-- Update the slider's value from the binding
function ValueSlider:UpdateFromBinding(defaults)
    -- Get the current value from the binding table or defaults
    local v = self._bindTable[self._bindKey] or (defaults and defaults[self._bindKey]) or self._min
    self:SetValue(v) -- Set the slider's value
    setValueText(self._valueText, v, self._format) -- Update the displayed value text
end

-- Register the Slider class in LibRu.Frames
LibRu.Frames.Slider = ValueSlider