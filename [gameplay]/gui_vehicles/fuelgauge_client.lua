local fuelgauge = nil
local timer = nil

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		fuelgauge = guiCreateProgressBar(.85, .93, .1, .02, true)
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if(vehicle and getVehicleOccupant(vehicle) == localPlayer) then
			onPlayerEnterVehicle(vehicle, 0)
		else
			guiSetVisible(fuelgauge, false)
		end
	end
)

function onPlayerEnterVehicle(vehicle, seat)
	if(seat == 0) then
		guiSetVisible(fuelgauge, true)
		updateFuelGauge(vehicle)
		timer = setTimer(updateFuelGauge, 5000, 0, vehicle)
	end
end

addEventHandler("onClientPlayerVehicleEnter", getRootElement(), onPlayerEnterVehicle)

addEventHandler("onClientPlayerVehicleExit", getRootElement(),
	function()
		if(timer) then
			killTimer(timer)
			guiSetVisible(fuelgauge, false)
		end
	end
)

function updateFuelGauge(vehicle)
	fuel = getElementData(vehicle, "fuel")
	def = exports["vehicles"]:getVehicleDefinition(getElementModel(vehicle))
	maxfuel = exports["vehicles"]:getVehicleDefinitionMaxFuel(def)
	guiProgressBarSetProgress(fuelgauge, 100*fuel/maxfuel)
end
