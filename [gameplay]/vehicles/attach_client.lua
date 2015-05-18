local packerID = 443

addEvent("onPackerRampMove", true)

bindKey("special_control_up", "down",
function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if(vehicle and getElementModel(vehicle) == packerID and getVehicleOccupant(vehicle, 0) == localPlayer) then
		triggerServerEvent("onPackerRampUp", localPlayer, vehicle)
	end
end)

bindKey("special_control_down", "down",
function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if(vehicle and getElementModel(vehicle) == packerID and getVehicleOccupant(vehicle, 0) == localPlayer) then
		triggerServerEvent("onPackerRampDown", localPlayer, vehicle)
	end
end)

function updateRamp(pos)
	setVehicleAdjustableProperty(source, pos)
end
addEventHandler("onPackerRampMove", getRootElement(), updateRamp)
