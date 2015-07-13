local lowHealth = 25
local repairAmount = 200
local startFire = 250

-- check regularily if a vehicle is burning
-- if one is burning make it damageproof
setTimer(
	function ( )
		for _, vehicle in ipairs(getElementsByType("vehicle")) do
			if getElementHealth(vehicle) <= startFire and getElementHealth(vehicle) > 0 and not isVehicleDamageProof(vehicle) and getElementData(vehicle, "id") then
				setElementHealth(vehicle, lowHealth);
				setVehicleDamageProof(vehicle, true)
				setVehicleEngineState(vehicle, false)
			end
		end
	end, 1000, 0
)

-- check if a bruning vehicles is hit with a fire extinguisher
-- if one is "repair" the vehicle until it stops burning
function vehicleFireFix(weapon, _, _, _, _, _, element)
	if weapon == 42 and element and getElementType(element) == "vehicle" and getElementData(element, "id") then
		local health = getElementHealth(element)
		if health < startFire and health > 0 then
			setElementHealth(element, health + 1)
			if(health + 1 > lowHealth + repairAmount) then
				setVehicleDamageProof(element, false)
				setElementHealth(element, startFire + 1)
			end
		end
	-- debug
	elseif weapon == 41 and element and getElementType(element) == "vehicle" and getElementData(element, "id") then
		local health = getElementHealth(element)
		if health >= startFire and health < 800 then
			setElementHealth(element, health + 1)
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", root, vehicleFireFix)
