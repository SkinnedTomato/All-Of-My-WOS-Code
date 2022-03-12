local touch = GetPartFromPort(1, "TouchScreen")
print(tostring(touch))
print("online")
local cursor
--[[
local mouseLoop = function()
    while wait(1) do
        if not cursor then
            print("lost the mouse")
            mouse()
            break
        end
    end
end
]]--
local mouse = function()
    while wait(1) do
        print("waiting")
        cursor = touch:GetCursor()
        print(tostring(cursor).. " ".. tostring(touch:GetCursor()))
        if cursor then
            print("got a mouse")
            --mouseLoop()
            break
        end
    end
end

local bg = touch:CreateElement("ImageLabel", {
	Image = "http://www.roblox.com/asset/?id=1376676034";
	Size = UDim2.new(1, 0, 1, 0);
	Position = UDim2.new(0, 0, 0, 0);
})
mouse()