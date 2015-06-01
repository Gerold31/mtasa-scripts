local engineFailure = 251

addEventHandler("onClientVehicleDamage", getRootElement(),
	function(_, _, loss)
		if(getElementHealth(source) - loss <= engineFailure) then
			setVehicleEngineState(source, false)
		end
	end
)

addEventHandler("onClientPlayerVehicleEnter",getRootElement(),
	function(vehicle, seat)
		if(getElementHealth(vehicle) <= engineFailure) then
			setVehicleEngineState(vehicle, false)
		end
	end
)

addCommandHandler("engine",
	function()
		vehicle = getPedOccupiedVehicle(localPlayer)
		if(vehicle) then
			if(getVehicleOccupant(vehicle, 0) == localPlayer) then
				if(getVehicleEngineState(vehicle)) then
					setVehicleEngineState(vehicle, false)
				elseif(getElementHealth(vehicle) > engineFailure) then
					setVehicleEngineState(vehicle, true)
				end
			else
				outputChatBox("You have to be the driver.")
			end
		else
			outputChatBox("You have to be in a car.")
		end
	end
)
