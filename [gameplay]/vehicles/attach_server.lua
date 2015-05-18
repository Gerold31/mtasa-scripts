local packerID = 443
local rampUp = 2500
local rampDown = 0
local slotsUp = 8
local slotsDown = 6
local animationSteps = 20

function spawnVehicle(vehid, x,y,z)
	return exports["utils"]:spawnVehicle(vehid, x,y,z)
end

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
	if(getElementModel(vehicle) == packerID) then
		rampState[vehicle] = 0
		mountedVehicles[vehicle] = {}
	end
end

function initResource()
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		initVehicle(vehicle)
	end
end
addEventHandler("onResourceStart", getRootElement(), initResource)

addEventHandler("onVehicleSpawn", getRootElement(), function() initVehicle(source) end)

function disableRamp(vehicle)
	if(getElementModel(vehicle) == packerID) then
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

	for s, child in pairs(mountedVehicles[vehicle]) do
		if(s > slotsUp) then break end
		if(child) then
			local px = (1-pos) * mountPoints[0][s][1] + pos * mountPoints[1][s][1]
			local py = (1-pos) * mountPoints[0][s][2] + pos * mountPoints[1][s][2]
			local pz = (1-pos) * mountPoints[0][s][3] + pos * mountPoints[1][s][3]
			local rx = (1-pos) * mountPoints[0][s][4] + pos * mountPoints[1][s][4]
			local ry = (1-pos) * mountPoints[0][s][5] + pos * mountPoints[1][s][5]
			local rz = (1-pos) * mountPoints[0][s][6] + pos * mountPoints[1][s][6]
			setElementAttachedOffsets(child, px,py,pz, rx,ry,rz)
		end
	end
end

function mountVehicle(player, command, vehicleID, slot)
	vehicleID = tonumber(vehicleID) or 522
	slot = tonumber(slot) or -1

	local vehicle = getPedOccupiedVehicle(player)

	if(vehicle and getElementModel(vehicle) == packerID) then
		if(slot < 1) then
			for i=1,slotsUp+slotsDown do
				if(not mountedVehicles[vehicle][i]) then
					slot = i
					break;
				end
			end
		end

		if(mountedVehicles[vehicle] and mountedVehicles[vehicle][slot]) then
			outputChatBox("There is already a vehicle in this slot", player)
			return
		end

		if(slot < 1 or slot > slotsUp+slotsDown) then
			outputChatBox("Vehicle is full", player)
			return
		end

		local pos = rampState[vehicle]

		local px
		local py
		local pz
		local rx
		local ry
		local rz

		if(slot > slotsUp) then
			if(pos > 1-1/animationSteps) then
				px = mountPoints[1][slot][1]
				py = mountPoints[1][slot][2]
				pz = mountPoints[1][slot][3]
				rx = mountPoints[1][slot][4]
				ry = mountPoints[1][slot][5]
				rz = mountPoints[1][slot][6]
			else
				outputChatBox("Move the ramp up first", player)
				return
			end
		else
			if(pos < 1/animationSteps) then
				px = (1.-pos) * mountPoints[0][slot][1] + pos * mountPoints[1][slot][1]
				py = (1.-pos) * mountPoints[0][slot][2] + pos * mountPoints[1][slot][2]
				pz = (1.-pos) * mountPoints[0][slot][3] + pos * mountPoints[1][slot][3]
				rx = (1.-pos) * mountPoints[0][slot][4] + pos * mountPoints[1][slot][4]
				ry = (1.-pos) * mountPoints[0][slot][5] + pos * mountPoints[1][slot][5]
				rz = (1.-pos) * mountPoints[0][slot][6] + pos * mountPoints[1][slot][6]
			else
				outputChatBox("Move the ramp down first", player)
				return
			end
		end

		x,y,z = getElementPosition(vehicle)

		v = spawnVehicle(vehicleID, x,y,z)

		attachElements(v, vehicle, px,py,pz, rx,ry,rz)

		if(not mountedVehicles[vehicle]) then mountedVehicles[vehicle] = {} end
		mountedVehicles[vehicle][slot] = v
	else
		outputChatBox("You have to be in a Packer", player)
	end
end
addCommandHandler("mount", mountVehicle)

function detachVehicles(player, command, slot)
	local vehicle = getPedOccupiedVehicle(player)
	if(vehicle and getElementModel(vehicle) == packerID and mountedVehicles[vehicle][tonumber(slot)]) then
		detachElements(mountedVehicles[vehicle][tonumber(slot)])
		mountedVehicles[vehicle][tonumber(slot)] = nil
	end
end
addCommandHandler("detach", detachVehicles)
