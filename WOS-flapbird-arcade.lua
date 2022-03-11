--Created by murpyh#3984
local Screen = GetPartFromPort(1, "Screen")
local Button = GetPartFromPort(2, "TriggerWire")
math.randomseed(SandboxRunID)
Screen:ClearElements()
local y = 0
local yv = 0
local timer = 0
local score = 0
local game = true

	
local bg = Screen:CreateElement("ImageLabel", {
	Image = "http://www.roblox.com/asset/?id=743475289";
	Size = UDim2.new(1, 0, 1, 0);
	Position = UDim2.new(0, 0, 0, 0);
})
local bird = Screen:CreateElement("ImageLabel", {
	Image = "http://www.roblox.com/asset/?id=148036904";
	Size = UDim2.new(0.15, 0, 0.1, 0);
	Position = UDim2.new(0.1, 0, 0, 0);
	BackgroundTransparency = 1;
})
local gameover = Screen:CreateElement("TextLabel", {
	Text = "";
	BackgroundTransparency = 1;
	TextColor3 = Color3.new(1, 1, 1);
	TextStrokeTransparency = 0;
	Size = UDim2.new(0.5, 0, 0.5, 0);
	Position = UDim2.new(0.25, 0, 0.25, 0);
	TextScaled = true;
	ZIndex = 5;
})
local restart = Screen:CreateElement("TextLabel", {
	Text = "";
	BackgroundTransparency = 1;
	TextColor3 = Color3.new(1, 1, 1);
	TextStrokeTransparency = 0;
	Size = UDim2.new(0.5, 0, 0.15, 0);
	Position = UDim2.new(0.25, 0, 0.65, 0);
	TextScaled = true;
	ZIndex = 5;
})

local pipes = {}

local restartEnabled = false

function Flap(key)
	if y > 0 and game then
		yv = -0.02
	end
	if not game and restartEnabled then
		restartEnabled = false
		y = 0
		yv = 0
		score = 0
		for i,v in pairs(pipes) do
			if v["pipe"] then
				v.pipe:Destroy()
			end
		end
		gameover:ChangeProperties({
			Text = "";
		})
		restart:ChangeProperties({
			Text = "";
		})
		pipes = {}
		game = true
	end
end

function Pipe(height, top)
	local pipe
	local pipey
	if top then
		pipey = 0
		pipe = Screen:CreateElement("Frame", {
			Size = UDim2.new(0.12, 0, height, 0);
			Position = UDim2.new(1, 0, 0, 0);
			BackgroundColor3 = Color3.new(0.2, 1, 0.2);
			BackgroundTransparency = 0;
			ZIndex = 2;
		})
	else
		pipey = 1 - height
		pipe = Screen:CreateElement("Frame", {
			Size = UDim2.new(0.12, 0, height, 0);
			Position = UDim2.new(1, 0, 1 - height, 0);
			BackgroundColor3 = Color3.new(0.2, 1, 0.2);
			BackgroundTransparency = 0;
			ZIndex = 2;
		})
	end
	table.insert(pipes, {pipe=pipe, x=1, y=pipey, width=0.12, height=height})
end

Pipe(0.4, false)
Pipe(0.2, true)

GetPort(2):ConnectToEvent("Triggered", Flap)
local scoregui = Screen:CreateElement("TextLabel", {
		Text = "0";
		TextColor3 = Color3.new(1, 1, 1);
		TextStrokeTransparency = 0;
		TextScaled = true;
		BackgroundTransparency = 1;
		Size = UDim2.new(0.2, 0, 0.2, 0);
		Position = UDim2.new(0.35, 0, 0, 0);
		ZIndex = 4;
	})


function AABBcoll(rectA, rectB)
    local ax2, bx2, ay2, by2 = rectA.x + rectA.width, rectB.x + rectB.width, rectA.y + rectA.height, rectB.y + rectB.height
    return ax2 > rectB.x and bx2 > rectA.x and ay2 > rectB.y and by2 > rectA.y
end

function GameOver()
	gameover:ChangeProperties({
		Text = "GAME OVER!"
	})
	restart:ChangeProperties({
		Text = "Click to restart";
	})
	restartEnabled = true
end

local function updatePipe(id)
	local v = pipes[id]
	v.x = v.x - 0.02
	v.pipe:ChangeProperties({
		Position = UDim2.new(v.x, 0, v.y, 0)
	})
	if AABBcoll({x=0.1; y=y; width=0.15; height=0.1}, v) then
		game = false
		GameOver()
	end
end

local function checkPipe(id)
	local v = pipes[id]
	if v.x < -0.15 then v.pipe:Destroy(); --table.remove(pipes, i)
	end
end
while true do
	if game then
		timer = timer + 0.1
		scoregui:ChangeProperties({
			Text = math.floor(score);
		})
		if timer > 5 then
			score = score + 1
			timer = 0
			local height = math.random(2, 5) / 10
			Pipe(0.6 - height, false)
			Pipe(height, true)
		end
		yv = yv + 0.001
		if yv > 0.5 then yv = 0.5 end
		y = y + yv
		bird:ChangeProperties({
			Position = UDim2.new(0.1, 0, y, 0);
		})
		
		--BE PREPARED FOR THE MOST HACKY BS YOU HAVE EVER SEEN
		--FOR YOU SEE, EVERY LOOP IN PILOT.LUA HAS A WAIT ADDED TO IT
		--SO ITS MORE EFFICIENT TO JUST HAVE A BUNCH OF THE SAME CODE
		if #pipes >= 1 then
			updatePipe(1)
		end
		if #pipes >= 2 then
			updatePipe(2)
		end
		if #pipes >= 3 then
			updatePipe(3)
		end
		if #pipes >= 4 then
			updatePipe(4)
		end
		
		if #pipes >= 4 then
			checkPipe(4)
		end
		if #pipes >= 3 then
			checkPipe(3)
		end
		if #pipes >= 2 then
			checkPipe(2)
		end
		if #pipes >= 1 then
			checkPipe(1)
		end
		
		if #pipes >= 5 then
			pipes[1].pipe:Destroy()
			pipes[2].pipe:Destroy()
			pipes[3].pipe:Destroy()
			pipes[4].pipe:Destroy()
			pipes = {}
		end
		
		if y > 0.9 then
			game = false
			GameOver()
		end
	end
end
