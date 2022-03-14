local screen = GetPartFromPort(GetPort(1), "Screen")
local keyboard = GetPartFromPort(GetPort(2),"Keyboard")
local restartport = GetPort(3)
local bins = GetPartsFromPort(4, "Bin")
local modem = GetPartFromPort(GetPort(5), "Modem")
local speaker = GetPartFromPort(GetPort(6), "Speaker")
local currentPage = 1
local waitingpassword = false
local correctpassword = false
local letters
local alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local previousPage = -1
local route = ""
local attempts = 0
local inProgress = false
local pressedKey = {}
local loaded = false
local editing = false
local list = {["notif"] = {
	["[Blackbox]"] = "A blackbox at \n[52,24,0,0]\n was tripped from an\n [inbound] warp.";
	["[Proximity]"] = "A person named \n[uglyface42]\n triggered your proximity\n sensor at\n [52,24,0,0].";
	["[App Error]"] = "Your [Power] application\n at 'Site [52::24]' has one\n or more problems.";
	["[filler]"] = "nothing to see here";
	["[snake]"] = "nothing to see here";
	["[dog]"] = "nothing to see here";
};
["whitelist"] = {
	["altaltgoku0987654321"] = "altaltgoku0987654321";
	["King_TIX1337"] = "King_TIX1337";
	["gamer_chillax"] = "gamer_chillax";
	["HitScoreDanceMan"] = "HitScoreDanceMan";
	["Helvetica_Neue"] = "Helvetica_Neue";
	["Reptilos"] = "Reptilos"
};
["power"] = {
	["Ice2"] =  981;
	["Water2"] =  981.25;
	["Water3"] =  981.5;
	["Water4"] =  981.75;
	["Water5"] =  982;
	["Ice3"] =  982.25;
	["Water6"] =  982.5;
	["Water7"] =  982.75;
	["Ice4"] =  983;
	["Water8"] =  983.25;
	["Ice5"] =  983.5;
};
["mining"] = {
	["Iron"] =  325;
	["Iron2"] =  325.25;
	["Iron3"] =  325.5;
	["Copper"] =  325.75;
	["Copper2"] =  326;
	["Grass"] =  326.25;
	["Grass2"] = 326.5;
	["Stick"] =  326.75;
	["Wood"] =  327;
	["Ice"] =  327.25;
	["Water"] =  327.5;
	["Quartz"] =  327.75;
	["Silicon"] =  328;
	["Sulfur"] =  328.25;
	["Flint"] =  328.5;
	["Stone"] =  328.75;
	["Sand"] =  329;
	["Uranium"] =  329.25;	
};
["production"] = {
	["Wire"] =  105;
	["Chute"] =  105.25;
	["Pipe"] =  105.5;
	["Gear"] =  105.75;
	["Rubber"] =  106;
	["Cloth"] =  106.25;
	["TriggerWire"] =  106.5;
	["Polysilicon"] =  106.75;
	["Glass"] =  107
}
["systemkeyword"] = "burger king and fries\n"
}
local detagify = {}
local detagifyDict = {}

local listOpt = {}
local Selection
local alarmstatus = true
local currentList = ""


function selectPrev()
	if Selection == nil or Selection.Text == "" then
			if inProgress then return end
			--speaker:Chat("new")
			Selection = listOpt[#listOpt]
			table.remove(listOpt,#listOpt)	
			Selection.Text = "<"..Selection.Text..">"
		else
			inProgress = true
			--speaker:Chat(Selection.Text.." was last")
			if not (string.find(Selection.Text,"<") or string.find(Selection.Text,">")) then return end
			table.insert(listOpt,1,Selection)
			Selection.Text = string.gsub(string.gsub(Selection.Text,"<",""),">","")
			Selection = listOpt[#listOpt]
			table.remove(listOpt,#listOpt)	
			Selection.Text = "<"..Selection.Text..">"
		end
		inProgress = false
	--speaker:Chat("end")
end

function selectNext()
	--speaker:Chat(Selection)
	--speaker:Chat(inProgress)
	if Selection == nil or Selection.Text == "" then
			if inProgress then return end
			--speaker:Chat("new")
			Selection = listOpt[1]
			table.remove(listOpt,1)
			Selection.Text = "<"..Selection.Text..">"
		else
			--speaker:Chat(Selection.Text.." was last")
			inProgress = true
			if not (string.find(Selection.Text,"<") or string.find(Selection.Text,">")) then return end
			table.insert(listOpt,Selection)
			Selection.Text = string.gsub(string.gsub(Selection.Text,"<",""),">","")
			Selection = listOpt[1]
			table.remove(listOpt,1)
			Selection.Text = "<"..Selection.Text..">"
		end
		inProgress = false
	--speaker:Chat("end")
end

function password()
	if waitingpassword then return false end
	waitingpassword = true
	correctpassword = false
	attempts = 0
	currentPage = 0
	text0.Text = "Back\n<E>"
	text1.Text = ""
	text2.Text = ""
	text3.Text = ""
	text4.Text = "Please type the system \n keyphrase into the keyboard \n (not your keyboard)"
	dadare = screen:CreateElement("TextLabel", {Text = "", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.5,0.9)})
	for i = 1,240 do
		if correctpassword == true then
			dadare:Destroy()
			return true
		end
		text5.Text = tostring(30 - math.floor(i/8)).." second(s) left to input"
		dadare.Text = tostring(3-attempts).." attempt(s) left"
		text5.Position = UDim2.fromScale(0.5,0.8)
		wait(0.125)
		if currentPage == 1 then break end 
		if attempts == 3 then break end
	end
	return false
end


function pressedKey.E()
	if currentPage == 1 then   
		TriggerPort(3)
	--elseif previousPage == 1 then
    elseif previousPage == -1 then
		screen:ClearElements()
		waitingpassword = false
        correctpassword = false
		editing = false
		currentPage = 1
		text0 = screen:CreateElement("TextLabel", {Text = "Restart\n<E>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.15,0.9)})
		text1 = screen:CreateElement("TextLabel", {Text = "Systems\n<R>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.4,0.9)})
		text2 = screen:CreateElement("TextLabel", {Text = "Edit...\n<T>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.625,0.9)})
		text3 = screen:CreateElement("TextLabel", {Text = "Notifs...\n<Y>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.85,0.9)})
		text4 = screen:CreateElement("TextLabel", {Text = "'Anti-Matter' Base OS\n V.0.0.9 \n\n To control, sit and press \n one of the buttons \n listed below.", TextSize = 25, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.5,0.5)})
		text5 = screen:CreateElement("TextLabel", {Text = "", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(2,2)})
        wait(0.125)
		text5.Text = ""
    else
        currentPage = previousPage
        pressedKey[route]()
		if loaded == true and editing == false then
			loaded = false
		end
	end
end



function pressedKey.R()

	page = {}
	page.A = function()

		currentPage = 2
		previousPage = -1
		editing = false
		text0.Text = "Back\n(I)\n<E>"
		text1.Text = "More...\n<R>"
		text2.Text = "Power\n<T>"
		text3.Text = "Weapons\n<Y>"
		text4.Text = "Page 1:\nMain System Controls"
	end

	page.B = function()
		currentPage = 5
		previousPage = 1
        route = "R"
		editing = false
		if listOpt[1] then
			for i,v in ipairs(listOpt) do
				v:Destroy()
			end
		end
		text0.Text = "Back\n(II)\n<E>"
		text1.Text = "Alarms\n<R>"
		text2.Text = "Mining\n<T>"
		text3.Text = "Production\n<Y>"
		text4.Text = "Page 1:\nMain System Controls\nPart 2"
	end

	page.C = function()
		currentPage = 6
		previousPage = 1
        route = "T"
		listOpt = {}
		if letters and #letters >= 1 then
			for i,v in ipairs(letters) do
				v:Destroy()
			end
		end
        text4.Text = "Loading..."
		local af = 0
		local xf = 0
		local inte = 1
		editing = true
		--speaker:Chat("loading list")
		for k,v in pairs(list.whitelist) do
            if k ~= nil then
				--speaker:Chat(k.." and "..v)
	    	    tate = screen:CreateElement("TextLabel", {Text = k, TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,-125+(af*250),0.5,-230+(xf*30))})
		        table.insert(listOpt,inte,tate)
				table.insert(detagify,inte,v)
				af+=1
		        if af == 2 then
		    	    af = 0
			        xf += 1
		        end
            end
			inte+=1
        end
		--speaker:Chat("haha")
		for i,v in ipairs(listOpt) do
			if(string.gsub(v.Text, "#", "")=="") then
				speaker:Chat("this one is tagged at "..i)
			end
			detagifyDict[v.Text] = detagify[i]
		end
		--speaker:Chat("done")
		text0.Text = "Back\n(II)\n<E>"
		text1.Text = "Next\nEntry\n<R>"
		text2.Text = "Previous\nEntry\n<T>"
		text3.Text = "Select\nEntry\n<Y>"
		text4.Text = ""
	end

	page.D = function()
		selectNext()
	end
    page.E = function()
        currentPage = 8
		previousPage = 2
		route = "R"
		local str = ""
		if alarmstatus then
			str = "ON"
		else
			str = "OFF"
		end


		text0.Text = "Back\n(III)\n<E>"
		text1.Text = "Toggle\n<R>"
		text2.Text = ""
		text3.Text = ""
		text4.Text = "Alarm status: "..str

    end
	page.F = function()
		selectNext()
	end
	page.H = function()
		alarmstatus = not alarmstatus
        if alarmstatus then
			str = "ON"
		else
			str = "OFF"
		end
        text4.Text = "Alarm status: "..str
	end

	page.L = function()
		previousPage = 3
		route = "R"
		--speaker:Chat(list.whitelist[string.gsub(string.gsub(Selection.Text,"<",""),">","")])
		list.whitelist[string.gsub(string.gsub(Selection.Text,"<",""),">","")] = nil
		--speaker:Chat(list.whitelist[string.gsub(string.gsub(Selection.Text,"<",""),">","")])
        Selection:Destroy()
		Selection = nil
        pressedKey.E()
	end
	


	if page[alphabet[currentPage]] ~= nil then
		page[alphabet[currentPage]]()
	else
		--speaker:Chat("Page function not found under R, got "..tostring(page[alphabet[currentPage]]).." trying to go to "..tostring(alphabet[currentPage]))
	end
	--return page
end



function pressedKey.T()
	page = {}
	page.A = function()
		if correctpassword or password() then
			currentPage = 3
			previousPage = -1
			editing = false
			if listOpt[1] then
				for i,v in ipairs(listOpt) do
					v:Destroy()
				end
				if Selection then
					Selection:Destroy()
				end
			end
			text0.Text = "Back\n(I)\n<E>"
			text1.Text = "White-list\n<R>"
			text2.Text = "System\nKey\n<T>"
			text3.Text = "Disk\nContents\n<Y>"
			text4.Text = "Page 2:\nSystem Editing"
			wait(0.125)
			text5.Position = UDim2.fromScale(2,2)
		else
			pressedKey.E()
		end
	end

	page.B = function()

	end

	page.C = function()
	end

	page.D = function()
		selectPrev()
	end
	page.E = function()
		currentPage = 9
		previousPage = 2
		route = "R"
		text4.Text = ""
		editing = true
		local af = 0
		local xf = 0
		--speaker:Chat(loaded)
		if not loaded then
			for k,v in pairs(list.mining) do
	            if k ~= nil then
	                if v ~= nil then
			    	    tate = screen:CreateElement("TextLabel", {Text = k, TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,-175+(af*175),0.5,-230+(xf*30))})
			    	    table.insert(listOpt,tate)
				        af+=1
				        if af == 3 then
				    	    af = 0
					        xf += 1
				        end
   		             end
	   	         end
			end
			loaded = true
		end
		text0.Text = "Back\n(III)\n<E>"
		text1.Text = "Next\nEntry\n<R>"
		text2.Text = "Previous\nEntry\n<T>"
		text3.Text = "More...\n<Y>"
	end

	page.F = function()
		selectPrev()
	end

    page.G = function()
        --speaker:Chat(string.gsub(string.gsub(Selection.Text,"<",""),">",""))
        list.notif[string.gsub(string.gsub(Selection.Text,"<",""),">","")] = nil
        Selection:Destroy()
        pressedKey.E()
    end
	if page[alphabet[currentPage]] ~= nil then
		page[alphabet[currentPage]]()
	else
		--speaker:Chat("Page function not found under T, got "..tostring(page[alphabet[currentPage]]).." trying to go to "..tostring(alphabet[currentPage]))
	end
	--return page
end



function pressedKey.Y()
	page = {}
	page.A = function()
		currentPage = 4
		previousPage = -1
		listOpt = {}
		local af = 0
		local xf = 0
		editing = true
		text0.Text = "Back\n(I)\n<E>"
		text1.Text = "Next\nEntry\n<R>"
		text2.Text = "Previous\nEntry\n<T>"
		text3.Text = "Select\nEntry\n<Y>"
		text4.Text = ""
		for k,v in pairs(list.notif) do
   	   	    if k ~= nil then
   	            if v ~= nil then
		    	    tate = screen:CreateElement("TextLabel", {Text = k, TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,-175+(af*175),0.5,-230+(xf*30))})
		    	    table.insert(listOpt,tate)
			        af+=1
			        if af == 3 then
			    	    af = 0
				        xf += 1
			        end
	            end
            end
		end
	end

	page.B = function()
	end

	page.C = function()
	end

	page.D = function()
        if Selection == nil then return end
		currentPage = 7
        previousPage = 1
        route = "Y"
		for i,v in ipairs(listOpt) do
			v:Destroy()
		end
		text0.Text = "Back\n(II)\n<E>"
		text1.Text = "Fix\nIssue\n<R>"
		text2.Text = "Delete\nIssue\n<T>"
		text3.Text = ""
		local rawtext = list.notif[string.gsub(string.gsub(Selection.Text,"<",""),">","")]
		text4.Text = rawtext
		Selection.Position = UDim2.fromScale(2,2)
	end

    page.E = function()
        --speaker:Chat("ah")
    end

	page.F = function()
		if Selection == nil then return end
		currentPage = 12
		previousPage = 3
		route = "R"
		if listOpt[1] ~= nil then
			for i,v in ipairs(listOpt) do
				v:Destroy()
			end
		end
		text4.Text = string.gsub(string.gsub(Selection.Text,"<",""),">","")
		Selection.Position = UDim2.fromScale(2,2)
		letters = {}
		for i = 1,#detagifyDict[string.gsub(string.gsub(Selection.Text,"<",""),">","")] do
			speaker:Chat(string.sub(detagifyDict[string.gsub(string.gsub(Selection.Text,"<",""),">","")],i,i))
			local bbb = screen:CreateElement("TextLabel", {Text = string.sub(detagifyDict[string.gsub(string.gsub(Selection.Text,"<",""),">","")],i,i), TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,-175+(i*15),0.5,-50)})
			table.insert(letters,bbb)
		end
		text0.Text = "Back\n(III)\n<E>"
		text1.Text = "Delete\nUser\n<R>"
		text2.Text = ""
		text3.Text = ""
	end

	page.I = function()
		currentPage = 10
		previousPage = 5
		route = "T"
		text0.Text = "Back\n(IV)\n<E>"
		text1.Text = "Next\nPage\n<R>"
		text2.Text = "Previous\nPage\n<T>"
	end
	page.J = function()
		currentPage = 11
		previousPage = 9
		route = "Y"
		text0.Text = "Back\n(V)\n<E>"
		text1.Text = "Typing\nMode\n<R>"
		text2.Text = "Select\nEntry\n<T>"
		text3.Text = ""
	end

	if page[alphabet[currentPage]] ~= nil then
		page[alphabet[currentPage]]()
	else
		--speaker:Chat("Page function not found under Y, got "..tostring(page[alphabet[currentPage]]).." trying to go to "..tostring(alphabet[currentPage]))
	end
	--return page
end
--[[
pagesMain = {
	["2"] = pressedKey.R()[page.A];
	["3"] = pressedKey.T()[page.A];
	["4"] = pressedKey.Y()[page.A];
	["5"] = pressedKey.R()[page.B];
	["6"] = pressedKey.R()[page.C];
	["7"] = pressedKey.Y()[page.B];
}

]]--



keyboard:Connect("TextInputted", function(text, player)
	if text=="get page\n" then
		speaker:Chat(currentPage)
	end
	if waitingpassword == true then
		--speaker:Chat("testing pass "..text)
		if text == list["systemkeyword"] then
			--speaker:Chat("pass accepted")
			correctpassword = true
		else
			correctpassword = false
			attempts+=1
		end
	end
end)

keyboard:Connect("KeyPressed", function(key)
	local a = string.gsub(tostring(key),"Enum.KeyCode.","")
	if pressedKey[a] ~= nil then
		speaker:Chat("Pressed key "..a)
		pressedKey[a]()
	end
end)
speaker:Chat(tostring(screen))
wait(0.5)
screen:ClearElements()
currentPage = 1
text0 = screen:CreateElement("TextLabel", {Text = "Restart\nSystem\n<E>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.15,0.9)})
text1 = screen:CreateElement("TextLabel", {Text = "Systems\n<R>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.4,0.9)})
text2 = screen:CreateElement("TextLabel", {Text = "Edit...\n<T>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.625,0.9)})
text3 = screen:CreateElement("TextLabel", {Text = "Notifs...\n<Y>", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.85,0.9)})
text4 = screen:CreateElement("TextLabel", {Text = "'Anti-Matter' Base OS\n V.0.0.9 \n\n To control, sit and press \n one of the buttons \n listed below.", TextSize = 25, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(0.5,0.5)})
text5 = screen:CreateElement("TextLabel", {Text = "", TextSize = 15, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.fromScale(2,2)})