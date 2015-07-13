addCommandHandler("light",
	function(player)
		vehicle = getPedOccupiedVehicle(player)
		if(vehicle and getElementData(vehicle, "id")) then
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

addCommandHandler("taxilight",
	function(player)
		if(isPedInVehicle(player)) then
			local vehicle = getPedOccupiedVehicle(player)
			if(getVehicleController(vehicle) == player and getElementData(vehicle, "id")) then
				local id = getElementModel(vehicle)
				if(id == 420 or id == 438) then
					setVehicleTaxiLightOn(vehicle, not isVehicleTaxiLightOn(vehicle))
				end
			end
		end
	end
)
