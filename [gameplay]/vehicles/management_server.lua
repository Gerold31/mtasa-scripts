-- @todo save upgrades, variant, lightstate (including taxi and siren), door locked
-- inventory, fuel

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
		   "health INTEGER, isDamageProof INTEGER, panel0 INTEGER, panel1 INTEGER, panel2 INTEGER, panel3 INTEGER, panel4 INTEGER, panel5 INTEGER, panel6 INTEGER, " ..
		   "door0 INTEGER, door1 INTEGER, door2 INTEGER, door3 INTEGER, door4 INTEGER, door5 INTEGER, doorR0 REAL, doorR1 REAL, doorR2 REAL, doorR3 REAL, doorR4 REAL, doorR5 REAL, " ..
		   "wheel0 INTEGER, wheel1 INTEGER, wheel2 INTEGER, wheel3 INTEGER, paintjob INTEGER, " ..
		   "color0r INTEGER, color0g INTEGER, color0b INTEGER, color1r INTEGER, color1g INTEGER, color1b INTEGER, color2r INTEGER, color2g INTEGER, color2b INTEGER, color3r INTEGER, color3g INTEGER, color3b INTEGER, " ..
		   "engine INTEGER, plate TEXT)")
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
	local def = getVehicleDefinition(id)
	if(not def) then return nil end
	local r = math.random
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local l = string.len(chars)
	local plate = ""
	for i=1,8 do
		local c = r(1,l)
		plate = plate .. string.sub(chars, c, c)
	end
	local qh = dbQuery(dbConnection, "INSERT INTO vehicles(vehicleID, posX, posY, posZ, rotX, rotY, rotZ, spawned, " ..
					   "health, isDamageProof, panel0, panel1, panel2, panel3, panel4, panel5, panel6, " ..
					   "door0, door1, door2, door3, door4, door5, doorR0, doorR1, doorR2, doorR3, doorR4, doorR5, " ..
					   "wheel0, wheel1, wheel2, wheel3, paintjob, " ..
					   "color0r, color0g, color0b, color1r, color1g, color1b, color2r, color2g, color2b, color3r, color3g, color3b, " ..
					   "engine, plate) " ..
					   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " ..
					   "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
					   id, x, y, z, 0, 0, 0, 0, 1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, r(3),
					   r(256), r(256), r(256), r(256), r(256), r(256), r(256), r(256), r(256), r(256), r(256), r(256), 0,
					   plate)
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
		local vehicle = createVehicle(row["vehicleID"], row["posX"],row["posY"],row["posZ"], row["rotX"],row["rotY"],row["rotZ"])
		if(vehicle) then
			setElementData(vehicle, "id", row["id"], false)

			setElementHealth(vehicle, row["health"])
			setVehicleDamageProof(vehicle, row["isDamageProof"] == 1 and true or false)
			for i=0,6 do
				setVehiclePanelState(vehicle, i, row["panel" .. i])
			end
			for i=0,5 do
				setVehicleDoorState(vehicle, i, row["door" .. i])
				setVehicleDoorOpenRatio(vehicle, i, row["doorR" .. i])
			end
			setVehicleWheelStates(vehicle, row["wheel0"], row["wheel1"], row["wheel2"], row["wheel3"])
			setVehiclePaintjob(vehicle, row["paintjob"])
			setVehicleColor(vehicle, row["color0r"], row["color0g"], row["color0b"], row["color1r"], row["color1g"], row["color1b"], row["color2r"], row["color2g"], row["color2b"], row["color3r"], row["color3g"], row["color3b"])
			setVehicleEngineState(vehicle, row["engine"] == 1 and true or false)
			setVehiclePlateText(vehicle, row["plate"])

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
	local door = {}
	local doorR = {}
	local wheel0, wheel1, wheel2, wheel3 = getVehicleWheelStates(vehicle)
	local paintjob = getVehiclePaintjob(vehicle)
	local r0, g0, b0, r1, g1, b1, r2, g2, b2, r3, g3, b3 = getVehicleColor(vehicle, true)
	local engine = getVehicleEngineState(vehicle)
	local plate = getVehiclePlateText(vehicle)
	for i=0,6 do
		panel[i] = getVehiclePanelState(vehicle, i)
	end
	for i=0,5 do
		door[i] = getVehicleDoorState(vehicle, i)
		doorR[i] = getVehicleDoorOpenRatio(vehicle, i)
	end
	dbExec(dbConnection, "UPDATE vehicles SET posX=?, posY=?, posZ=?, rotX=?, rotY=?, rotZ=?, " ..
		   "health=?, isDamageProof=?, panel0=?, panel1=?, panel2=?, panel3=?, panel4=?, panel5=?, panel6=?, " ..
		   "door0=?, door1=?, door2=?, door3=?, door4=?, door5=?, door0=?, doorR1=?, doorR2=?, doorR3=?, doorR4=?, doorR5=?, " ..
		   "wheel0=?, wheel1=?, wheel2=?, wheel3=?, paintjob=?, " ..
		   "color0r=?, color0g=?, color0b=?, color1r=?, color1g=?, color1b=?, color2r=?, color2g=?, color2b=?, color3r=?, color3g=?, color3b=?, " ..
		   "engine=?, plate=? WHERE id=?",
		   x,y,z, rx,ry,rz, health, isDamageProof, panel[0], panel[1], panel[2], panel[3], panel[4], panel[5], panel[6],
		   door[0], door[1], door[2], door[3], door[4], door[5], doorR[0], doorR[1], doorR[2], doorR[3], doorR[4], doorR[5],
		   wheel0, wheel1, wheel2, wheel3, paintjob, r0, g0, b0, r1, g1, b1, r2, g2, b2, r3, g3, b3, engine, plate, id)
end
