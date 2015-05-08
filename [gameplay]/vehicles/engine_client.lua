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
