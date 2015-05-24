VehicleDefinitions = {}

function getVehicleDefinition(id)
	if (VehicleDefinitions[id] == nil) then
		invalid_call("Invalid id of vehicle definition.")
		return nil
	end
	return setmetatable({id=id}, VehicleDefinition)
end

function getVehicleDefinitionId(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.id
end

function getVehicleDefinitionName(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.name
end

function getVehicleDefinitionLocalizedName(definition, lang)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	lang = lang or getLocalization().code
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end

	local name = data.localisations[lang]
	if (name == nil) then
		return data.name
	else
		return name
	end
end

function getVehicleDefinitionType(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.type
end

function getVehicleDefinitionGVWR(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.gvwr
end

function getVehicleDefinitionSize(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.size
end

function getVehicleDefinitionInventories(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = VehicleDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid vehicle definition.")
		return nil
	end
	return data.inventories
end

function doVehicleDefinitionToString(definition)
	return "{VehicleDefinition:" .. definition.id .. "}"
end

VehicleDefinition = {
	getId = getVehicleDefinitionId,
	getName = getVehicleDefinitionName,
	getLocalizedName = getVehicleDefinitionLocalizedName,
	getType = getVehicleDefinitionType,
	getGVWR = getVehicleDefinitionGVWR,
	getSize = getVehicleDefinitionSize,
	getInventories = getVehicleDefinitionInventories,
	__tostring = doVehicleDefinitionToString
}
VehicleDefinition.__index = VehicleDefinition


function reloadVehicleDefinitions()
	local xmlRoot = XML.load("vehicledefinitions_shared.xml")
	if (xmlRoot:getName() ~= "vehicles") then
		outputDebugString("Invalid root node in vehicledefinitions_shared.xml.", 1)
		return
	end

	VehicleDefinitions = {}
	for _, node in ipairs(xmlRoot:getChildren()) do
		if (node:getName() == "vehicle") then
			-- read attributes of vehicle tag
			local id = node:getAttribute("id")
			local name = node:getAttribute("name")
			local vehicletype = node:getAttribute("type")
			local gvwr = node:getAttribute("gvwr")
			local size = node:getAttribute("size")

			-- interpret attributes
			---- id
			id = tonumber(id)
			---- name
			if (name == false) then
				name = nil
			end
			---- gvwr
			gvwr = tonumber(gvwr)
			---- size
			if (size == false) then
				size = -1
			else
				size = tonumber(size)
			end


			-- check for invalid attributes
			local valid = true
			if (id == nil) then valid = false end
			if (vehicletype == nil) then valid = false end
			if (gvwr == nil) then valid = false end

			if (not valid or VehicleDefinitions[id] ~= nil) then
				outputDebugString("Skip vehicle in vehicledefinitions_shared.xml: " .. tostring(id), 1)
			else
				-- create vehicle definition
				local definition = {
					["id"]=id,
					["name"]=name,
					["type"]=vehicletype,
					["gvwr"]=gvwr,
					["size"]=size,
					["localisations"]={},
					["inventories"]={}
				}
				for _, vehiclenode in ipairs(node:getChildren()) do
					if (vehiclenode:getName() == "desc") then
						local dname = vehiclenode:getAttribute("name")
						local dlang = vehiclenode:getAttribute("lang")
						if (dname == false) then
							outputDebugString("Invalid 'desc'-tag for vehicle '" .. tostring(id) .. "'.", 1)
						else
							if (dlang == false) then
								definition["name"] = dname
							else
								definition["localisations"][dlang] = dname
							end
						end
					elseif (vehiclenode:getName() == "inventory") then
						local key = vehiclenode:getAttribute("key")
						local volume = vehiclenode:getAttribute("volume")
						if (key == false or volume == false) then
							outputDebugString("Invalid 'inventory'-tag for vehicle '" .. tostring(id) .. "'.", 1)
						else
							definition["inventories"][key] = volume
						end
					else
						outputDebugString("Invalid tag in vehicledefinitions_shared.xml: " .. tostring(vehiclenode:getName()), 2)
					end
				end
				VehicleDefinitions[id] = definition
			end
		else
			outputDebugString("Invalid tag in vehicledefinitions_shared.xml: " .. tostring(node:getName()), 2)
		end
	end

	-- TODO xmlRoot:unload()
	xmlUnloadFile(xmlRoot)
end
addEventHandler("onResourceStart", resourceRoot, reloadVehicleDefinitions, false, "high+1")
addEventHandler("onClientResourceStart", resourceRoot, reloadVehicleDefinitions, false, "high+1")
