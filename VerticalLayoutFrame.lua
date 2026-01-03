-- LibRu = LibRu or {};

-- LibRu.VerticalLayoutFrame = LibRu.VerticalLayoutFrame or {};
-- local VerticalLayoutFrame = LibRu.VerticalLayoutFrame;

-- --[[
--     Creates an instance of the VerticalLayoutGroupClass.
--     By default it sets all points to the parent. You can override this.
-- ]]
-- function VerticalLayoutFrame:New(parent, frameName)
--     local instance = LibRu.Frame:New("Frame", frameName, parent)

--     -- Get the existing metatable of the Frame (could be a table or function)
--     local frameMeta = getmetatable(instance)

--     -- Create a new metatable for obj that merges Frame and CollapsiblePanelContentFrame
--     setmetatable(instance, {
--         __index = function(t, k)
--             -- Check VerticalLayoutGroupClass first
--             if VerticalLayoutFrame[k] then return VerticalLayoutFrame[k] end
            
--             -- Check if the Frame metatable has an __index (table or function)
--             if frameMeta and type(frameMeta.__index) == "table" then
--                 return frameMeta.__index[k]  -- Standard table lookup
--             elseif frameMeta and type(frameMeta.__index) == "function" then
--                 return frameMeta.__index(t, k)  -- Call function-based lookup
--             end
            
--             return nil  -- Key not found
--         end
--     })

--     return instance
-- end

-- function VerticalLayoutFrame:ApplyLayout(recursive)
--     -- re-orders contents according to content.orderIndex
--     print("Start function")

--     -- get all contents
--     local contents = LibRu.GetAllChildObjects(self);
    
--     if (#contents == 0) then return end;

--     -- apply recursion if necessary
--     if (recursive) then
--         for i = 1, #contents, 1 do 
--             if contents[i].ApplyLayout then 
--                 contents[i]:ApplyLayout(recursive);
--             end
--         end
--     end
    

--     --sort by orderIndex Ascending
--     table.sort(contents, function(a, b) 
--         return (a.orderIndex or 0) < (b.orderIndex or 0)
--     end);

--     -- 1st element is anchored to content frame itself
--     contents[1]:SetPoint("TOPLEFT")
--     contents[1]:SetPoint("TOPRIGHT")
    
--     -- other elements's top are anchored to the previous element's bottoms.
--     for i = 2, #contents, 1 do
--         print("Running!");
--         contents[i]:SetPoint("TOPLEFT", contents[i-1], "BOTTOMLEFT");
--         contents[i]:SetPoint("TOPRIGHT", contents[i-1], "BOTTOMRIGHT");
--     end
-- end