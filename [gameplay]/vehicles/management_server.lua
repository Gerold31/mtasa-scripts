local dbConnection = nil

addEvent("onVehicleSpawn")

function initResource()
	dbConnection = dbConnect("sqlite", "vehicles.db")
	if(not dbConnection) then
		outputServerLog("Failed to connect to database")
		cancelEvent()
		return
	end
	dbExec(dbConnection, "CREATE TABLE IF NOT EXISTS vehicles(id INTEGER PRIMARY KEY, vehicleID INTEGER, posX REAL, posY REAL, posZ REAL, rotX REAL, rotY REAL, rotZ REAL, spawned INTEGER)")
	dbQuery(
		function(qh)
			local result = dbPoll(qh, 0)
			if result then
				for _, row in ipairs(result) do
					local vehicle = spawnVehicle(row["vehicleID"], row["posX"], row["posY"], row["posZ"], row["rotX"], row["rotY"], row["rotZ"])
					setElementData(vehicle, "id", row["id"], false)
				end
			end
		 end, dbConnection, "SELECT id, vehicleID, posX, posY, posZ, rotX, rotY, rotZ FROM `vehicles` WHERE spawned == 1")
end
addEventHandler("onResourceStart", getRootElement(), initResource)


function stopResource()
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		local id = getElementData(vehicle, "id")
		if(not id) then
			ouputServerLog("Vehicle has no id!")
		else
			x,y,z = getElementPosition(vehicle)
			rx,ry,rz = getElementRotation(vehicle)
			dbExec(dbConnection, "UPDATE vehicles SET posX=?, posY=?, posZ=?, rotX=?, rotY=?, rotZ=? WHERE id=?", x,y,z, rx,ry,rz, id)
		end
	end
end
addEventHandler("onResourceStop", getRootElement(), stopResource)

function create(id, x, y, z)
	-- @todo verify id
	local qh = dbQuery(dbConnection, "INSERT INTO vehicles(vehicleID, posX, posY, posZ, rotX, rotY, rotZ, spawned) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", id, x, y, z, 0, 0, 0, 0)
	local _, _, vid = dbPoll(qh, -1)
	return tostring(vid)
end

function spawn(id, player)
	dbQuery(
		function(qh)
			local result, num_affected_rows = dbPoll(qh, 0)
			if result then
				if(num_affected_rows == 1) then
					local row = result[1]
					if(row["spawned"] == 1) then
						outputChatBox("Vehicle is already spawned", player)
					else
						local vehicle = spawnVehicle(row["vehicleID"], row["posX"], row["posY"], row["posZ"], row["rotX"], row["rotY"], row["rotZ"])
						if(vehicle) then
							setElementData(vehicle, "id", row["id"], false)
							dbExec(dbConnection, "UPDATE vehicles SET spawned='1' WHERE id=?", row["id"])
						else
							outputChatBox("Cannot spawn Vehicle", player)
							-- @todo delete db entry?
						end
					end
				else
					outputChatBox("Vehicle doesn't exist", player)
				end
			end
		end, dbConnection, "SELECT id, vehicleID, posX, posY, posZ, rotX, rotY, rotZ FROM `vehicles` WHERE id == ?", id)
end

function despawn(id, player)
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		if(getElementData(vehicle, "id") == id) then
			x,y,z = getElementPosition(vehicle)
			rx,ry,rz = getElementRotation(vehicle)
			destroyElement(vehicle)
			dbExec(dbConnection, "UPDATE vehicles SET posX=?, posY=?, posZ=?, rotX=?, rotY=?, rotZ=?, spawned='0' WHERE id=?", x,y,z, rx,ry,rz, id)
			return
		end
	end
	outputChatBox("Vehicle isn't spawned or doesn't exist", player)
end

function spawnVehicle(id, x, y, z, rx, ry, rz)
	local def = getVehicleDefinition(id)
	if(def) then
		local veh = createVehicle(id, x,y,z, rx,ry,rz)
		if(veh) then
			local invs = getVehicleDefinitionInventories(def)
			for key, vol in pairs(invs) do
				exports["inventory"]:addInventory(veh, key, vol)
				-- debug
				--local item = exports["inventory"]:getItemDefinition(1)
				--local succ = exports["inventory"]:addInventoryItem(exports["inventory"]:getInventory(veh, key), item, 1000)
				--if(not succ) then outputServerLog("failed") end
			end
			triggerEvent("onVehicleSpawn", veh)
		end
		return veh
	end
	return nil
end

