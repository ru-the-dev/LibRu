local addon, ns = ...
if ns.LibRu == nil then return end

local LibRu = ns.LibRu

local EnumFlag = {}
LibRu.EnumFlag = EnumFlag

-- Create an EnumFlag from either a name->value map or a list of names.
-- Map example: { DISPLAY = 1, INFO = 2 }
-- List example: { "DISPLAY", "INFO", "WARNING" }
---@param enum table
---@return table
function EnumFlag.Create(enum)
	if type(enum) ~= "table" then
		error("EnumFlag.Create expects a table (map or list).")
	end

	local enumValues = {}

	-- Detect list form (numeric keys)
	local isList = true
	for k in pairs(enum) do
		if type(k) ~= "number" then
			isList = false
			break
		end
	end

	if isList then
		local index = 0
		for _, name in ipairs(enum) do
			index = index + 1
			if type(name) ~= "string" or name == "" then
				error("EnumFlag.Create expects non-empty string names in list.")
			end
			enumValues[name] = bit.lshift(1, index - 1)
		end
	else
		for name, value in pairs(enum) do
			if type(name) ~= "string" or name == "" then
				error("EnumFlag.Create expects string keys for enum map.")
			end
			if type(value) ~= "number" then
				error("EnumFlag.Create expects numeric values for enum map.")
			end
			enumValues[name] = value
		end
	end

	return setmetatable({
		Value = 0,
		Enum = enumValues,
	}, { __index = EnumFlag })
end


--- Set a single flag by name
---@param self table
---@param flag string
function EnumFlag:SetFlag(flag)
	local flagValue = self.Enum[flag]
	if not flagValue then
		error("Invalid flag name: " .. tostring(flag))
	end
	self.Value = bit.bor(self.Value, flagValue)
end


--- Set one or more flags by name
---@param self table
---@param ... string
function EnumFlag:SetFlags(...)
	for i = 1, select('#', ...) do
		local flag = select(i, ...)
		local flagValue = self.Enum[flag]
		if not flagValue then
			error("Invalid flag name: " .. tostring(flag))
		end
		self.Value = bit.bor(self.Value, flagValue)
	end
end


--- Clear one or more flags by name
---@param self table
---@param ... string
function EnumFlag:ClearFlags(...)
	for i = 1, select('#', ...) do
		local flag = select(i, ...)
		local flagValue = self.Enum[flag]
		if not flagValue then
			error("Invalid flag name: " .. tostring(flag))
		end
		self.Value = bit.band(self.Value, bit.bnot(flagValue))
	end
end


--- Check if all provided flags are set
---@param self table
---@param ... string
---@return boolean
function EnumFlag:HasFlags(...)
	for i = 1, select('#', ...) do
		local flag = select(i, ...)
		local flagValue = self.Enum[flag]
		if not flagValue then
			error("Invalid flag name: " .. tostring(flag))
		end
		if bit.band(self.Value, flagValue) == 0 then
			return false
		end
	end
	return true
end


