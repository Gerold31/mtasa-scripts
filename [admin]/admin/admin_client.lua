
function getVehicleHandlingProperty(element, property)
	return exports["utils"]:getVehicleHandlingProperty(element, property)
end

addCommandHandler("labels",
	function()
		for _, vehicle in pairs(getElementsByType('vehicle')) do
			x,y,z = getElementPosition(vehicle)
			c = getVehicleHandlingProperty(vehicle, "centerOfMass")
			id = getElementModel(vehicle)
			local text = exports["3dTextLabel"]:create3DTextLabel("id: " .. id ..
			"\nmass: " .. getVehicleHandlingProperty(vehicle, "mass") ..
			"\npos: " .. x .. "," .. y .. "," .. z ..
			"\ncmass: " .. c[1] .. "," .. c[2] .. "," .. c[3],
			tocolor(255, 255, 255, 255), x, y, z) -- dtawing the text
		end
	end
)

addCommandHandler("devmode",
function()
	setDevelopmentMode(true)
end
)
