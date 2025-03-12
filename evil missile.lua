local lifeSensor = GetPartFromPort(GetPort(1), "LifeSensor")
local instrument = GetPartFromPort(GetPort(1), "Instrument")
local gyro = GetPartFromPort(GetPort(1), "Gyro")
local switch = GetPartFromPort(GetPort(1), "Switch")

local targetWhitelist = {["a"] = true, ["HitScoredanceMan"] = true, ["michaelosei"] = true, ["Gustavo12345687890"] = true}

local target = "a"

local str = target.." Max2147483647"

local sampleSize = 30

local posReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}
local speedReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}
local accReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}

local pitbull = {{}, 1}
local deltaPitbull = {{}, 1}

local deltaErrorRatio = 0.0155
local gravity = 50

local rrra = {}
local aaar = {}
local velocities = table.create(5, Vector3.new(0,0,0))
local speeds = table.create(15, 0)

local beepiterator = 0

local impulseMode = false

local pitchScale = 300
local pitchOffset = 15
local speedScale = 0.125
local speedOffset = 15
local maxPitch = 5
local minPitch = 0.5
local minSpeed = 0.03125
local maxSpeed = 1
local orgMissileSpeed = 500
local missileSpeed = orgMissileSpeed

local outrunIterator = 1
local iterator = 1
local velIterator = 1
local speedIterator = 1
local init = true
local lastFiredImpulse = tick()
local previousPos instrument:GetReading("Position")
local currentPos = instrument:GetReading("Position")
local flying = false
local targetFoundIterator = 1

local function arrayAverage(array) --Returns the average of the array's elements (assuming all elements can arithmetic with eachother)
    if #array>0 then
        arrayTotal = array[1]*0
        for _,v in ipairs(array) do
            arrayTotal+=v
        end
        return arrayTotal/#array
    end
    return array[1]*0
end

local function iteratorSub(iterator, sub, size) --Returns (iterator - sub), unless the result is less than 1, then it returns an overflow based on size.
    if iterator-sub > 0 and iterator and sub and size then
        return iterator-sub
    elseif iterator and sub and size then
        return size - sub + iterator
    end
    warn("iteratorSub did not return a valid iterator")
    return 1
end

local function iteratorAdd(iterator, add, size) --Returns (iterator + add), unless the result is greater than size, then it returns an overflow based on size.
    if iterator and add and size and iterator+add <= size  then
        return iterator+add
    elseif iterator and add and size then
        return iterator + add - size
    end
    warn("iteratorAdd did not return a valid iterator")
    return 1
end

local function getTrustedSpeed()
    if flying then
        return orgMissileSpeed
    end
    return arrayAverage(speeds)
end

local master = 1

while true do
    local waited = task.wait()
    for k,v in pairs(lifeSensor:GetReading()) do
        if init and target==k then
            init = false
            print("init")
            posReadings = {table.create(sampleSize, v), 1}
            speedReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}
            accReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1} 
            GetPartFromPort(GetPort(1), "Anchor"):Configure({["Anchored"] = false})
            switch:Configure({["SwitchValue"] = true})
            task.wait(1)
            flying = true
        elseif target == "a" and not targetWhitelist[k] then
            target = k
            GetPartFromPort(GetPort(1), "Anchor"):Configure({["Anchored"] = false})
            posReadings = {table.create(sampleSize, v), 1}
            speedReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}
            accReadings = {table.create(sampleSize, Vector3.new(0,0,0)), 1}
            switch:Configure({["SwitchValue"] = true})
            task.wait(1)
            flying = true
        elseif targetWhitelist[k] then
            if target == k then
                target = "a"
                switch:Configure({["SwitchValue"] = false})
                GetPartFromPort(GetPort(1), "Anchor"):Configure({["Anchored"] = true})
                flying = false
            end
        end
        if k == target then
            targetFoundIterator = 1
            previousPos = currentPos
            currentPos = instrument:GetReading("Position")
            speeds[speedIterator] = instrument:GetReading("Speed")
            speedIterator = iteratorAdd(speedIterator, 1, 15)
            --print(arrayAverage(speeds))
            velocities[velIterator] = currentPos-previousPos
            velIterator = iteratorAdd(velIterator, 1, 5)
            --print(currentPos)
            beepiterator+=1
            posReadings[1][posReadings[2]] = v
            if posReadings[1][iteratorSub(posReadings[2],1,sampleSize)] then
                speedReadings[1][speedReadings[2]] = (posReadings[1][posReadings[2]] - posReadings[1][iteratorSub(posReadings[2],1,sampleSize)]) / waited
                if speedReadings[1][iteratorSub(speedReadings[2],1,sampleSize)] then
                    accReadings[1][accReadings[2]] = (speedReadings[1][speedReadings[2]] - speedReadings[1][iteratorSub(speedReadings[2],1,sampleSize)]) / waited
                    accReadings[2] = iteratorAdd(accReadings[2], 1, sampleSize)
                end
                speedReadings[2] = iteratorAdd(speedReadings[2], 1, sampleSize)
            end
            posReadings[2] = iteratorAdd(posReadings[2], 1, sampleSize)
            aaar[iterator] = waited
            iterator = iteratorAdd(iterator, 1, 60)
            --print(arrayAverage(accReadings[1]).Y)
            local targetVelocity = arrayAverage(speedReadings[1])*(arrayAverage(aaar)/deltaErrorRatio)
            --print(targetVelocity.Magnitude)
            local timeForMissile = (v-currentPos).Magnitude/getTrustedSpeed()
            local guessedPosition = v+targetVelocity*timeForMissile + (arrayAverage(accReadings[1])*timeForMissile)
            for i = 1,5 do
                timeForMissile = (guessedPosition-currentPos).Magnitude/getTrustedSpeed()
                if impulseMode then
                    guessedPosition = v+((targetVelocity-arrayAverage(velocities)).Unit*instrument:GetReading("Speed")*timeForMissile) + ((arrayAverage(accReadings[1])+Vector3.new(0,gravity,0))*timeForMissile)
                else
                    guessedPosition = v+targetVelocity*timeForMissile+(arrayAverage(accReadings[1])*timeForMissile)
                end
            end
            if not pitbull[1][1] then
                pitbull[1] = table.create(sampleSize, timeForMissile)
            end
            if not deltaPitbull[1][1] then
                deltaPitbull[1] = table.create(sampleSize, pitbull[1][pitbull[2]] - pitbull[1][iteratorSub(pitbull[2], 1, sampleSize)])
            end
            pitbull[1][pitbull[2]] = timeForMissile
            pitbull[2] = iteratorAdd(pitbull[2], 1, sampleSize)
            deltaPitbull[1][deltaPitbull[2]] = pitbull[1][pitbull[2]] - pitbull[1][iteratorSub(pitbull[2], 1, sampleSize)]
            deltaPitbull[2] = iteratorAdd(deltaPitbull[2], 1, sampleSize)
            if arrayAverage(deltaPitbull[1]) < 0 then
                --print("Target is going faster than me")
                outrunIterator += 1
            else
                outrunIterator = 1
                switch:Configure({["SwitchValue"] = true})
                task.delay(1, function() flying = true end)
                impulseMode = false
            end
            if outrunIterator > 25 then
                print("Time to target is trending towards infinity! Readings: impact in "..tostring(arrayAverage(pitbull[1])).." ; target speed is "..tostring(arrayAverage(speedReadings[1]).Magnitude).." ; my speed is "..tostring(arrayAverage(speeds)))
                --[[
                switch:Configure({["SwitchValue"] = false})
                flying = false
                --task.delay(0.875, function() missileSpeed+=1500 end)
                impulseMode = true
                ]]--
            end
            if ((arrayAverage(velocities).Unit) + (guessedPosition-currentPos).Unit).Magnitude < 1 then
                print("I'm moving away from the target!")
                gyro:Configure({["Seek"] = str})
            end
            --if (currentPos-v).Magnitude > 100 then
            if tostring((guessedPosition-currentPos).Unit.X) == tostring(0/0) or tostring((guessedPosition-currentPos).Unit.Y) == tostring(0/0) or tostring((guessedPosition-currentPos).Unit.Z) == tostring(0/0) then
                print("Trying to point at NaN!!!")
                gyro:Configure({["Seek"] = str})
            else
                gyro:PointAt(guessedPosition)
            end
             --gyro:PointAt(guessedPosition)
            --else
                --gyro:PointAt(v)
            --end
            --[[
            if impulseMode then
                if tick() - lastFiredImpulse >1.125 then
                    print("Firing")
                    print("Fired")
                    missileSpeed+=1500
                    lastFiredImpulse = tick()
                end
            end
            ]]--
            if beepiterator > math.clamp(math.min(speedScale * (currentPos-v).Magnitude-speedOffset), 60*minSpeed, 60*maxSpeed) then
                Beep(math.clamp(pitchScale/math.max((currentPos-v).Magnitude-pitchOffset, 0.01), minPitch, maxPitch))
                --print(pitchScale/math.max((currentPos-v).Magnitude-pitchOffset, 0.01))
                if (currentPos-v).Magnitude < 75 then 
                    master+=1
                else
                    master = 1
                end
                if master>5 then
                    switch:Configure({["SwitchValue"] = false})
                    TriggerPort(2)
                end
                beepiterator = 0
            end
        else
            targetFoundIterator+=1
        end
        if targetFoundIterator>60 then 
            print("Target lost")
            target = "a"
            switch:Configure({["SwitchValue"] = false})
            GetPartFromPort(GetPort(1), "Anchor"):Configure({["Anchored"] = true})
            flying = false
            impulseMode = false
        end
    end
end
