addEvent("onVehicleSpawn")

function spawnVehicle(id, x, y, z)
	local def = getVehicleDefinition(id)
	if(def) then
		local veh = createVehicle(id,x,y,z)
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

