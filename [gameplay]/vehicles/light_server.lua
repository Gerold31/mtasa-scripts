addCommandHandler("light",
	function(player)
		vehicle = getPedOccupiedVehicle(player)
		if(vehicle) then
			if(getVehicleOccupant(vehicle, 0) == player) then
				local light = getVehicleOverrideLights(vehicle)
				if(light ~= 2) then
					setVehicleOverrideLights(vehicle, 2)
				else
					setVehicleOverrideLights(vehicle, 1)
				end
			else
				outputChatBox("You have to be the driver.")
			end
		else
			outputChatBox("You have to be in a car.")
		end
	end
)
