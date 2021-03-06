local engineFailure = 251

function toggleEngine(vehicle, toggle)
	if(toggle == nil) then
		toggle = not getVehicleEngineState(vehicle)
	end
	if(not toggle) then
		setVehicleEngineState(vehicle, false)
	else
		if(getElementHealth(vehicle) > engineFailure and getElementData(vehicle, "fuel") > 0) then
			setVehicleEngineState(vehicle, true)
		else
			setVehicleEngineState(vehicle, false)
		end
	end
end

addEventHandler("onClientVehicleDamage", getRootElement(),
	function(_, _, loss)
		if(getElementHealth(source) - loss <= engineFailure and getElementData(source, "id")) then
			setVehicleEngineState(source, false)
		end
	end
)

addEventHandler("onClientPlayerVehicleEnter",getRootElement(),
	function(vehicle, seat)
		if(getElementData(vehicle, "id")) then
			toggleEngine(vehicle, getVehicleEngineState(vehicle))
		end
	end
)

addCommandHandler("engine",
	function()
		vehicle = getPedOccupiedVehicle(localPlayer)
		if(vehicle and getElementData(vehicle, "id")) then
			if(getVehicleOccupant(vehicle, 0) == localPlayer) then
				toggleEngine(vehicle)
			else
				outputChatBox("You have to be the driver.")
			end
		else
			outputChatBox("You have to be in a car.")
		end
	end
)
