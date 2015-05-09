addEvent("onVehicleSpawn")

function spawnVehicle(id, x, y, z)
	veh = createVehicle(id,x,y,z)
	if(veh) then
		triggerEvent("onVehicleSpawn", veh)
	end
	return veh
end

