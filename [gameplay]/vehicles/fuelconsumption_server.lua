local idleconsumption = 0.5/60/60
setTimer(
	function ( )
		for _, vehicle in ipairs(getElementsByType("vehicle")) do
			if(getVehicleEngineState(vehicle) and getElementData(vehicle, "id")) then
				vx,vy,vz = getElementVelocity(vehicle)
				speed = (vx^2 + vy^2 + vz^2)^0.5 * 180
				local def = getVehicleDefinition(getElementModel(vehicle))
				local consumption = getVehicleDefinitionFuelConsumption(def)*speed/360000
				consumption = math.max(consumption, idleconsumption)
				local newfuel = math.max(getElementData(vehicle, "fuel") - consumption, 0)
				setElementData(vehicle, "fuel", newfuel)
				if(newfuel == 0) then
					setVehicleEngineState(vehicle, false)
				end
				--outputChatBox("vehicle " .. getVehiclePlateText(vehicle) .. " consumed " .. tonumber(consumption) .. " fuel, new level: " .. tonumber(getElementData(vehicle, "fuel")))
			end
		end
	end, 1000, 0
)

function onElementDataChange(data, old)
	if(data == "fuel" and getElementType(source) == "vehicle") then
		if(client ~= nil) then
			outputServerLog("Player '" .. tostring(getPlayerName(client)) .. "' tried to change a fuel level.")
			setElementData(source, data, old)
		elseif(sourceResource ~= getThisResource()) then
			outputServerLog("Resource '" .. tostring(getResourceName(sourceResource)) .. "' tried to change a fuel level.")
			setElementData(source, data, old)
		end
	end
end
addEventHandler("onElementDataChange", getResourceRootElement(getThisResource()), onElementDataChange)
