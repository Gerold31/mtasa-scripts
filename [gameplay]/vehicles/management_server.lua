local dbConnection = nil

addEvent("onVehicleSpawn")

function initResource()
	dbConnection = dbConnect("sqlite", "vehicles.db")
	if(not dbConnection) then
		outputServerLog("Failed to connect to database")
		cancelEvent()
		return
	end
	dbExec(dbConnection, "CREATE TABLE IF NOT EXISTS vehicles(id INTEGER PRIMARY KEY, vehicleID INTEGER, posX REAL, posY REAL, posZ REAL, rotX REAL, rotY REAL, rotZ REAL, spawned INTEGER, " ..
		   "health INTEGER, isDamageProof INTEGER, panel0 INTEGER, panel1 INTEGER, panel2 INTEGER, panel3 INTEGER, panel4 INTEGER, panel5 INTEGER, panel6 INTEGER)")
	dbQuery(
		function(qh)
			local result = dbPoll(qh, 0)
			if result then
				for _, row in ipairs(result) do
					local vehicle = spawnVehicle(row)
					if(not vehicle) then
						outputServerLog("failed to Spawn vehicle")
					end
				end
			end
		 end, dbConnection, "SELECT * FROM `vehicles` WHERE spawned == 1")
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), initResource)


function stopResource()
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		local id = getElementData(vehicle, "id")
		if(not id) then
			ouputServerLog("Vehicle has no id!")
		else
			saveVehicle(vehicle)
		end
	end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), stopResource)

function create(id, x, y, z)
	-- @todo verify id
	local qh = dbQuery(dbConnection, "INSERT INTO vehicles(vehicleID, posX, posY, posZ, rotX, rotY, rotZ, spawned, " ..
					   "health, isDamageProof, panel0, panel1, panel2, panel3, panel4, panel5, panel6) " ..
					   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
					   id, x, y, z, 0, 0, 0, 0, 1000, 0, 0, 0, 0, 0, 0, 0, 0)
	local _, _, vid = dbPoll(qh, -1)
	return tostring(vid)
end

function delete(id, player)
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		if(getElementData(vehicle, "id") == id) then
			destroyElement(vehicle)
		end
	end
	dbExec(dbConnection, "DELETE FROM vehicles WHERE id=?", id)
end

function spawn(id, player)
	dbQuery(
		function(qh)
			local result, num_affected_rows = dbPoll(qh, 0)
			if result then
				if(num_affected_rows == 1 and result[1]) then
					local row = result[1]
					if(row["spawned"] == 1) then
						outputChatBox("Vehicle is already spawned", player)
					else
						local vehicle = spawnVehicle(row)
						if(vehicle) then
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
		end, dbConnection, "SELECT * FROM `vehicles` WHERE id == ?", id)
end

function despawn(id, player)
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		if(getElementData(vehicle, "id") == id) then
			saveVehicle(vehicle)
			destroyElement(vehicle)
			dbExec(dbConnection, "UPDATE vehicles SET spawned='0' WHERE id=?", id)
			return
		end
	end
	outputChatBox("Vehicle isn't spawned or doesn't exist", player)
end

function spawnVehicle(row)
	local def = getVehicleDefinition(row["vehicleID"])
	if(def) then
		local vehicle = createVehicle(row["vehicleID"], row["posX"],row["posY"],row["posZ"], row["rotX"],row["rotZ"],row["rotZ"])
		if(vehicle) then
			setElementData(vehicle, "id", row["id"], false)

			setElementHealth(vehicle, row["health"])
			setVehicleDamageProof(vehicle, row["isDamageProof"] == 1 and true or false)
			for i=0,6 do
				setVehiclePanelState(vehicle, i, row["panel" .. i])
			end

			-- inventory
			local invs = getVehicleDefinitionInventories(def)
			for key, vol in pairs(invs) do
				exports["inventory"]:addInventory(vehicle, key, vol)
				-- debug
				--local item = exports["inventory"]:getItemDefinition(1)
				--local succ = exports["inventory"]:addInventoryItem(exports["inventory"]:getInventory(veh, key), item, 1000)
				--if(not succ) then outputServerLog("failed") end
			end
			triggerEvent("onVehicleSpawn", vehicle)
		end
		return vehicle
	end
	return nil
end

function saveVehicle(vehicle)
	local id = getElementData(vehicle, "id")
	local x,y,z = getElementPosition(vehicle)
	local rx,ry,rz = getElementRotation(vehicle)
	local health = getElementHealth(vehicle)
	local isDamageProof = isVehicleDamageProof(vehicle) and 1 or 0
	local panel = {}
	for i=0,6 do
		panel[i] = getVehiclePanelState(vehicle, i)
	end
	dbExec(dbConnection, "UPDATE vehicles SET posX=?, posY=?, posZ=?, rotX=?, rotY=?, rotZ=?, " ..
		   "health=?, isDamageProof=?, panel0=?, panel1=?, panel2=?, panel3=?, panel4=?, panel5=?, panel6=? WHERE id=?",
		   x,y,z, rx,ry,rz, health, isDamageProof, panel[0], panel[1], panel[2], panel[3], panel[4], panel[5], panel[6], id)
end
