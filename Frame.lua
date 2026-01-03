-- LibRu = LibRu or {}
-- LibRu.Frame = LibRu.Frame or {}

-- local Frame = LibRu.Frame

-- --- [Documentation](https://warcraft.wiki.gg/wiki/API_CreateFrame)
-- ---@generic T, Tp
-- ---@param frameType `T` | FrameType
-- ---@param frameName? string Name of the frame
-- ---@param parentFrame? any Parent frame
-- ---@param template? `Tp` | Template
-- ---@return table | T | Tp Frame The created frame
-- function Frame:New(frameType, frameName, parentFrame, template)
--     local instance = CreateFrame(frameType, frameName, parentFrame, template)

--     -- Retrieve the existing Blizzard Frame metatable
--     local frameMeta = getmetatable(instance)

--     -- Set a metatable that extends both Blizzard's Frame and LibRu's Frame
--     setmetatable(instance, {
--         __index = function(t, k)
--             return Frame[k] or (frameMeta and frameMeta.__index and (type(frameMeta.__index) == "table" and frameMeta.__index[k] or frameMeta.__index(t, k)))
--         end
--     })

--     instance.heightMode = "auto"

--     return instance
-- end

-- --- Adjusts the height of a frame to fit its content by checking the highest and lowest child boundaries.
-- ---@param recursive boolean Whether to run the same function on child elements
-- ---@param ignoreHidden boolean Whether to ignore hidden children
-- ---@param recursionLevel? integer Current recursion level (leave nil)
-- function Frame:FitHeightToContent(recursive, ignoreHidden, recursionLevel)
--     recursionLevel = recursionLevel or 0  -- Default recursion level

--     local getAllChildObjects = LibRu.GetAllChildObjects
--     local fitFrameHeightToContent = LibRu.FitFrameHeightToContent

--     -- Fetch child elements
--     local contents = getAllChildObjects(self)
--     if not contents or #contents == 0 then return end

--     -- Recursively adjust child heights if required
--     if recursive then
--         for _, child in ipairs(contents) do
--             if child.FitHeightToContent then
--                 child:FitHeightToContent(true, ignoreHidden, recursionLevel + 1)
--             end
--         end
--     end

--     -- Adjust height at the top level or if heightMode is set to "auto"
--     if recursionLevel == 0 or self.heightMode == "auto" then
--         fitFrameHeightToContent(self, ignoreHidden)
--     end
-- end
