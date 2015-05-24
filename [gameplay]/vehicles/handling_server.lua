function getVehicleHandlingProperty(element, property)
	return exports["utils"]:getVehicleHandlingProperty(element, property)
end

function updateHandling(vehicle)
	local invs = exports["inventory"]:getInventories(vehicle)
	if(invs) then
		local additionalMass = 0
		for key, inv in pairs(invs) do
			additionalMass = additionalMass + exports["inventory"]:getInventoryMass(inv)
		end

		local mass = getVehicleHandlingProperty(getElementModel(vehicle), "mass")
		local turnMass = getVehicleHandlingProperty(getElementModel(vehicle), "turnMass")
		local engineAcceleration = getVehicleHandlingProperty(getElementModel(vehicle), "engineAcceleration")
		local brakeDeceleration = getVehicleHandlingProperty(getElementModel(vehicle), "brakeDeceleration")
		local turnMassR = turnMass/mass
		local engineF = mass * engineAcceleration
		local brakeF = mass * brakeDeceleration
		local totalMass = mass+additionalMass
		setVehicleHandling(vehicle, "mass", totalMass)
		setVehicleHandling(vehicle, "turnMass", turnMass+additionalMass*turnMassR)
		setVehicleHandling(vehicle, "engineAcceleration", engineF/totalMass)
		setVehicleHandling(vehicle, "brakeDeceleration", brakeF/totalMass)
	end
end
addEventHandler("onVehicleSpawn", getRootElement(), function() updateHandling(source) end)
addEventHandler("onInventorySetItemAmount", getRootElement(), function() updateHandling(source) end)
addEventHandler("onInventorySetItems", getRootElement(), function() updateHandling(source) end)

function initResource()
	for _, vehicle in pairs(getElementsByType('vehicle')) do
		updateHandling(vehicle)
	end
end
addEventHandler("onResourceStart", getRootElement(), initResource)
