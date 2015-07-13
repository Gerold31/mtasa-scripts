local packerID = 443
local rampUp = 2500
local rampDown = 0
local slotsUp = 8
local slotsDown = 6
local animationSteps = 20

local mountPoints = { [0] = {
	{-0.8, 2.30,2.35, 15,0,0},
	{ 0.8, 2.30,2.35, 15,0,0},
	{-0.8,-0.54,1.60, 15,0,0},
	{ 0.8,-0.54,1.60, 15,0,0},
	{-0.8,-3.38,0.85, 15,0,0},
	{ 0.8,-3.38,0.85, 15,0,0},
	{-0.8,-6.22,0.10, 15,0,0},
	{ 0.8,-6.22,0.10, 15,0,0}
}, [1] = {
	{-0.8, 2.6,2.15, 0,0,0},
	{ 0.8, 2.6,2.15, 0,0,0},
	{-0.8,-0.31,2.15, 0,0,0},
	{ 0.8,-0.31,2.15, 0,0,0},
	{-0.8,-3.22,2.15, 0,0,0},
	{ 0.8,-3.22,2.15, 0,0,0},
	{-0.8,-6.13,2.15, 0,0,0},
	{ 0.8,-6.13,2.15, 0,0,0},

	{-0.8,-0.1, 0.40, 0,0,0},
	{ 0.8,-0.1, 0.40, 0,0,0},
	{-0.8,-2.5, 0.40, 0,0,0},
	{ 0.8,-2.5, 0.40, 0,0,0},
	{-0.8,-5.5, 0.23, 15,0,0},
	{ 0.8,-5.5, 0.23, 15,0,0}
} }

local rampState = {} -- 0: ramp down, 1: ramp up

local mountedVehicles = {}

addEvent("onPackerRampUp", true)
addEvent("onPackerRampDown", true)

function initVehicle(vehicle)
	if(getElementModel(vehicle) == packerID and getElementData(vehicle, "id")) then
		rampState[vehicle] = 0
		mountedVehicles[vehicle] = {}
	end
end

function initResource()
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		if(getElementData(vehicle, "id")) then
			initVehicle(vehicle)
		end
	end
end
addEventHandler("onResourceStart", getRootElement(), initResource)

addEventHandler("onVehicleSpawn", getRootElement(), function() initVehicle(source) end)

function disableRamp(vehicle)
	if(getElementModel(vehicle) == packerID and getElementData(vehicle, "id")) then
		toggleControl(source, "special_control_up", false)
		toggleControl(source, "special_control_down", false)
		local pos = rampState[vehicle]
		if(pos >= 1/animationSteps and pos < 0.5) then
			steps = pos*animationSteps
			setTimer(function()
				local newPos = rampState[vehicle] - 1/animationSteps
				movePackerRamp(vehicle, newPos)
			end, 50, steps)
		elseif(pos >= 0.5 and pos <= 1-1/animationSteps) then
			steps = (1-pos)*animationSteps
			setTimer(function()
				local newPos = rampState[vehicle] + 1/animationSteps
				movePackerRamp(vehicle, newPos)
			end, 50, steps)
		end
	else
		toggleControl(source, "special_control_up", true)
		toggleControl(source, "special_control_down", true)
	end
end
addEventHandler("onPlayerVehicleEnter", getRootElement(), disableRamp)

function onRampUp(vehicle)
	if(rampState[vehicle] < 1/animationSteps) then
		rampState[vehicle] = 0

		setTimer(function()
			local newPos = rampState[vehicle] + 1/animationSteps
			movePackerRamp(vehicle, newPos)
		end, 50, animationSteps)
	end
end
addEventHandler("onPackerRampUp", getRootElement(), onRampUp)

function onRampDown(vehicle)
	if(rampState[vehicle] > 1-1/animationSteps) then
		for i=slotsUp+1,slotsUp+slotsDown do
			if(mountedVehicles[vehicle][i]) then
				outputChatBox("Remove vehicles in the lower level first.", source)
				return
			end
		end

		rampState[vehicle] = 1
		setTimer(function()
			local newPos = rampState[vehicle] - 1/animationSteps
			movePackerRamp(vehicle, newPos)
		end, 50, animationSteps)

	end
end
addEventHandler("onPackerRampDown", getRootElement(), onRampDown)

function movePackerRamp(vehicle, pos)
	if(not getVehicleOccupant(vehicle, 0)) then return end

	rampState[vehicle] = pos

	triggerClientEvent(getVehicleOccupant(vehicle, 0), "onPackerRampMove", vehicle, (1-pos) * rampDown + pos * rampUp)

	local off = 0;
	for s=1,slotsUp do
		if(s+off > slotsUp) then break end
		local child = mountedVehicles[vehicle][s+off]
		if(child) then
			local size = getVehicleDefinitionSize(getVehicleDefinition(getElementModel(child)))
			local px = 0
			local py = 0
			local pz = 0
			local rx = 0
			local ry = 0
			local rz = 0
			for i=0,size-1 do
				px = px + (1-pos) * mountPoints[0][s+i+off][1] + pos * mountPoints[1][s+i+off][1]
				py = py + (1-pos) * mountPoints[0][s+i+off][2] + pos * mountPoints[1][s+i+off][2]
				pz = pz + (1-pos) * mountPoints[0][s+i+off][3] + pos * mountPoints[1][s+i+off][3]
				rx = rx + (1-pos) * mountPoints[0][s+i+off][4] + pos * mountPoints[1][s+i+off][4]
				ry = ry + (1-pos) * mountPoints[0][s+i+off][5] + pos * mountPoints[1][s+i+off][5]
				rz = rz + (1-pos) * mountPoints[0][s+i+off][6] + pos * mountPoints[1][s+i+off][6]
			end
			px = px	/ size
			py = py	/ size
			pz = pz	/ size
			rx = rx	/ size
			ry = ry	/ size
			rz = rz	/ size
			setElementAttachedOffsets(child, px,py,pz, rx,ry,rz)
			off = off + size - 1
		end
	end
end

function getNextFreeSlot(vehicle, size)
	if(size == 1) then
		for i=1,slotsUp+slotsDown do
			if(not mountedVehicles[vehicle][i]) then
				return i;
			end
		end
	else
		local i
		for i=1,slotsUp-size+1,2 do
			local accepted = true
			for j=0,size-1 do
				if(mountedVehicles[vehicle][i+j]) then
					accepted = false
					break
				end
			end
			if(accepted) then return i end
		end
		for i=slotsUp+1,slotsUp+slotsDown-size+1,2 do
			local accepted = true
			for j=0,size-1 do
				if(mountedVehicles[vehicle][i+j]) then
					accepted = false
					break
				end
			end
			if(accepted) then return i end
		end
	end
end

function checkPath(vehicle, slot, size)
	if(size == 1) then
		if(slot <= slotsUp-2) then
			for i=slot+2,slotsUp,2 do
				if(mountedVehicles[vehicle][i]) then return false end
			end
		else
			for i=slot+2,slotsUp+slotsDown,2 do
				if(mountedVehicles[vehicle][i]) then return false end
			end
		end
	else
		if(slot <= slotsUp) then
			for i=slot+size,slotsUp do
				if(mountedVehicles[vehicle][i]) then return false end
			end
		else
			for i=slot+size,slotsUp+slotsDown do
				if(mountedVehicles[vehicle][i]) then return false end
			end
		end
	end
	return true
end

function mountVehicle(player, command, vehicleID, slot)
	vehicleID = tonumber(vehicleID) or 522
	slot = tonumber(slot) or -1
	local size = getVehicleDefinitionSize(getVehicleDefinition(vehicleID))
	if(not size or size == -1) then
		outputChatBox("This vehicle can't be mounted.")
		return
	end

	local vehicle = getPedOccupiedVehicle(player)

	if(vehicle and getElementModel(vehicle) == packerID and getElementData(vehicle, "id")) then
		if(slot < 1) then
			slot = getNextFreeSlot(vehicle, size)
		end

		if(size > 1 and slot % 2 == 0) then
			slot = slot-1
		end


		for i=0,size-1 do
			if(mountedVehicles[vehicle][slot+i]) then
				outputChatBox("There is already a vehicle in this slot", player)
				return
			end
		end

		if(not checkPath(vehicle, slot, size)) then
			outputChatBox("The Path is blocked by another vehicle", player)
			return
		end

		if(slot < 1 or slot > slotsUp+slotsDown) then
			outputChatBox("Vehicle is full", player)
			return
		end

		local pos = rampState[vehicle]

		local px = 0
		local py = 0
		local pz = 0
		local rx = 0
		local ry = 0
		local rz = 0

		if(slot > slotsUp) then
			if(pos > 1-1/animationSteps) then
				for i=0,size-1 do
					px = px + mountPoints[1][slot+i][1]
					py = py + mountPoints[1][slot+i][2]
					pz = pz + mountPoints[1][slot+i][3]
					rx = rx + mountPoints[1][slot+i][4]
					ry = ry + mountPoints[1][slot+i][5]
					rz = rz + mountPoints[1][slot+i][6]
				end
			else
				outputChatBox("Move the ramp up first", player)
				return
			end
		else
			if(pos < 1/animationSteps) then
				for i=0,size-1 do
					px = px + mountPoints[0][slot+i][1]
					py = py + mountPoints[0][slot+i][2]
					pz = pz + mountPoints[0][slot+i][3]
					rx = rx + mountPoints[0][slot+i][4]
					ry = ry + mountPoints[0][slot+i][5]
					rz = rz + mountPoints[0][slot+i][6]
				end
			else
				outputChatBox("Move the ramp down first", player)
				return
			end
		end

		px = px / size
		py = py / size
		pz = pz / size
		rx = rx / size
		ry = ry / size
		rz = rz / size

		x,y,z = getElementPosition(vehicle)

		v = spawnVehicle(vehicleID, x,y,z)

		attachElements(v, vehicle, px,py,pz, rx,ry,rz)

		if(not mountedVehicles[vehicle]) then mountedVehicles[vehicle] = {} end

		for i=0,size-1 do
			mountedVehicles[vehicle][slot+i] = v
		end
	else
		outputChatBox("You have to be in a Packer", player)
	end
end
addCommandHandler("mount", mountVehicle)

function detachVehicles(player, command, slot)
	slot = tonumber(slot)
	local vehicle = getPedOccupiedVehicle(player)
	if(vehicle and getElementModel(vehicle) == packerID and mountedVehicles[vehicle][slot] and getElementData(vehicle, "id")) then
		local child = mountedVehicles[vehicle][slot]
		local size = getVehicleDefinitionSize(getVehicleDefinition(getElementModel(getElementModel(child))))
		for i=slot,0,-1 do
			if(mountedVehicles[vehicle][i] ~= child) then break end
			slot = i
		end
		if(not checkPath(vehicle, slot, size)) then
			outputChatBox("The Path is blocked by another vehicle", player)
			return
		end
		detachElements(child)
		for i=slot,slot+size-1 do
			mountedVehicles[vehicle][i] = nil
		end
	end
end
addCommandHandler("detach", detachVehicles)
