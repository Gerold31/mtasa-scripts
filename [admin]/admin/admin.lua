-- @todo restric access

function getVehicleHandlingProperty(vehid, prop)
	return call(getResourceFromName("utils"), "getVehicleHandlingProperty", vehid, prop)
end

function spawnVehicle(vehid, x,y,z)
	return call(getResourceFromName("utils"), "spawnVehicle", vehid, x,y,z)
end

-- set Vehicle Handling property
function setVH(thePlayer, command, prop, val)
	local vehid = getPedOccupiedVehicle(thePlayer)
	if(vehid ~= false) then
		local ret = setVehicleHandling(vehid, prop, val)
		if(ret == false) then
			outputChatBox("Error setting Vehicle Handling", thePlayer)
		end
	else
		outputChatBox("You have to be in a vehicle.", thePlayer)
	end
end
addCommandHandler("setVH", setVH)

-- print Vehicle Handling property to chat
function getVH(thePlayer, command, prop)
	local vehid = getPedOccupiedVehicle(thePlayer)
	if(vehid ~= false) then
		local m = getVehicleHandlingProperty(vehid, prop)
		if(m == false) then
			outputChatBox("Error getting Vehicle Handling", thePlayer)
		else
			if(type(m) == number) then
				outputChatBox(prop .. ": " .. tonumber(m), thePlayer)
			else
				outputChatBox(prop .. ": " .. m, thePlayer)
			end
		end
	else
		outputChatBox("You have to be in a vehicle.", thePlayer)
	end
end
addCommandHandler("getVH", getVH)

-- spawns vehicle near player
function createVehicleForPlayer(thePlayer, command, vehicleModel)
	local x,y,z = getElementPosition(thePlayer) -- get the position of the player
	x = x + 5 -- add 5 units to the x position
	local createdVehicle = spawnVehicle(tonumber(vehicleModel),x,y,z)
	-- check if the return value was ''false''
	if (createdVehicle == false) then
		-- if so, output a message to the chatbox, but only to this player.
		outputChatBox("Failed to create vehicle.",thePlayer)
	end
end
addCommandHandler("cv", createVehicleForPlayer)

-- gives weapon to player
function createWeapon(thePlayer, command, weaponid)
	giveWeapon(thePlayer, weaponid, 500)
end
addCommandHandler("cw", createWeapon)
