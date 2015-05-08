
-- check regularily if a vehicle is burning
-- if one is burning make it damageproof
setTimer(
	function ( )
		for _, vehicle in ipairs(getElementsByType("vehicle")) do
			if getElementHealth(vehicle) <= 250 and getElementHealth(vehicle) > 0 and not isVehicleDamageProof(vehicle) then
				setElementHealth(vehicle, 10);
				setVehicleDamageProof(vehicle, true)
			end
		end
	end, 1000, 0
)

-- check if a bruning vehicles is hit with a fire extinguisher
-- if one is "repair" the vehicle until it stops burning
function vehicleFireFix(weapon, _, _, _, _, _, element)
	if weapon == 42 and element and getElementType(element) == "vehicle" then
		local health = getElementHealth(element)
		if health < 251 and health > 0 then
			setElementHealth(element, health + 1)
			if(health + 1 > 250) then
				setVehicleDamageProof(element, false)
			end
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", root, vehicleFireFix)
