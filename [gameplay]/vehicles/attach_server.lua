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

local vehicleSize = {
 [581] = 1, [510] = 1, [509] = 1, [522] = 1, [481] = 1, [461] = 1, [462] = 1, [448] = 1, [521] = 1, [468] = 1, [463] = 1, [586] = 1,
 [523] = 1, [441] = 1, [594] = 1, [501] = 1, [564] = 1, [471] = 1,
 [572] = 2, [464] = 2, [571] = 2, [610] = 2, [465] = 2,
 [602] = 4, [545] = 4, [496] = 4, [517] = 4, [401] = 4, [410] = 4, [518] = 4, [600] = 4, [527] = 4, [436] = 4, [589] = 4, [580] = 4,
 [419] = 4, [439] = 4, [533] = 4, [549] = 4, [526] = 4, [491] = 4, [474] = 4, [445] = 4, [426] = 4, [507] = 4, [547] = 4, [585] = 4,
 [405] = 4, [587] = 4, [550] = 4, [492] = 4, [566] = 4, [546] = 4, [540] = 4, [551] = 4, [421] = 4, [516] = 4, [529] = 4, [438] = 4,
 [574] = 4, [420] = 4, [596] = 4, [597] = 4, [598] = 4, [531] = 4, [543] = 4, [422] = 4, [478] = 4, [605] = 4, [536] = 4, [575] = 4,
 [535] = 4, [576] = 4, [402] = 4, [542] = 4, [603] = 4, [475] = 4, [568] = 4, [424] = 4, [504] = 4, [539] = 4, [429] = 4, [411] = 4,
 [541] = 4, [559] = 4, [415] = 4, [561] = 4, [480] = 4, [560] = 4, [562] = 4, [506] = 4, [565] = 4, [451] = 4, [434] = 4, [558] = 4,
 [494] = 4, [555] = 4, [502] = 4, [477] = 4, [503] = 4, [404] = 4, [479] = 4, [458] = 4, [606] = 4, [607] = 4, [611] = 4, [485] = 4,
 [409] = 6, [534] = 6, [412] = 6, [467] = 6, [604] = 6, [466] = 6,
}

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

	local off = 0;
	for s=1,slotsUp do
		if(s+off > slotsUp) then break end
		local child = mountedVehicles[vehicle][s+off]
		if(child) then
			local size = vehicleSize[getElementModel(child)]
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

function mountVehicle(player, command, vehicleID, slot)
	vehicleID = tonumber(vehicleID) or 522
	slot = tonumber(slot) or -1
	local size = vehicleSize[vehicleID]
	if(not size) then
		outputChatBox("This vehicle can't be mounted.")
		return
	end

	local vehicle = getPedOccupiedVehicle(player)

	if(vehicle and getElementModel(vehicle) == packerID) then
		if(slot < 1) then
			slot = getNextFreeSlot(vehicle, size)
		end


		for i=0,size-1 do
			if(mountedVehicles[vehicle][slot+i]) then
				outputChatBox("There is already a vehicle in this slot", player)
				return
			end
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
	local vehicle = getPedOccupiedVehicle(player)
	if(vehicle and getElementModel(vehicle) == packerID and mountedVehicles[vehicle][tonumber(slot)]) then
		detachElements(mountedVehicles[vehicle][tonumber(slot)])
		mountedVehicles[vehicle][tonumber(slot)] = nil
	end
end
addCommandHandler("detach", detachVehicles)
