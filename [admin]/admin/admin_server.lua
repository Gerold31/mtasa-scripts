-- @todo restric access

vehicleMass = {}

local vehicleIDs = exports["utils"]:getVehicleIDs();

function getVehicleHandlingProperty(vehid, prop)
	return call(getResourceFromName("utils"), "getVehicleHandlingProperty", vehid, prop)
end

function createVehicle(vehid, x,y,z, player)
	return call(getResourceFromName("vehicles"), "create", vehid, x,y,z, player)
end

function deleteVehicle(id, player)
	return call(getResourceFromName("vehicles"), "delete", id, player)
end

function spawnVehicle(id, player)
	return call(getResourceFromName("vehicles"), "spawn", id, player)
end

function despawnVehicle(id, player)
	return call(getResourceFromName("vehicles"), "despawn", id, player)
end

for i, id in pairs(vehicleIDs) do
	local mass = getVehicleHandlingProperty(id, "mass")
	vehicleMass[i] = {id, mass};
end

table.sort(vehicleMass,
function(a,b)
	return a[2] < b[2]
end
)

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

-- creates vehicle near player
function createVehicleForPlayer(thePlayer, command, vehicleModel)
	local x,y,z = getElementPosition(thePlayer) -- get the position of the player
	x = x + 5 -- add 5 units to the x position
	local createdVehicle = createVehicle(tonumber(vehicleModel),x,y,z, thePlayer)
	-- check if the return value was ''false''
	if(createdVehicle) then
		-- if so, output a message to the chatbox, but only to this player.
		outputChatBox("Created vehicle " .. createdVehicle,thePlayer)
	end
end
addCommandHandler("cv", createVehicleForPlayer)

-- deletes vehicle
addCommandHandler("dv", function(player, command, id) deleteVehicle(tonumber(id), player) end)

-- spawns vehicle
addCommandHandler("spawn", function(player, command, id) spawnVehicle(tonumber(id), player) end)

-- despawns vehicle
addCommandHandler("despawn", function(player, command, id) despawnVehicle(tonumber(id), player) end)

-- gives weapon to player
function createWeapon(thePlayer, command, weaponid)
	giveWeapon(thePlayer, weaponid, 500)
end
addCommandHandler("cw", createWeapon)

-- prints current position in chat
function printPos(thePlayer, command)
	local x,y,z = getElementPosition(thePlayer)
	outputChatBox("Pos: " .. round(x, 2) .. "," .. round(y, 2) .. "," .. round(z, 2), thePlayer)
end
addCommandHandler("pos", printPos)

-- spawns all Vehicles at LS International
function spawnAll(thePlayer, command)
	local x,y,z = 1410, -2494, 15
	setElementPosition(thePlayer, x,y,z)
	for _, id in pairs(vehicleMass) do
		if(getVehicleType(id[1]) == "Automobile") then
			spawnVehicle(id[1],x,y,z)
			x = x + 5
			if(x>=2070) then x, y = 1410, -2593 end
		end
	end
end
addCommandHandler("spawnAll", spawnAll)

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
