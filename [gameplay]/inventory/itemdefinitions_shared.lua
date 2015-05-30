ItemDefinitions = {}

function getItemDefinition(id)
	if (ItemDefinitions[id] == nil) then
		invalid_call("Invalid id of item definition.")
		return nil
	end
	return setmetatable({id=id}, ItemDefinition)
end

function getItemDefinitionId(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return data.id
end

function getItemDefinitionName(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return data.name
end

function getItemDefinitionLocalizedName(definition, lang)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	lang = lang or getLocalization().code
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end

	local name = data.localisations[lang]
	if (name == nil) then
		return data.name
	else
		return name
	end
end

function getItemDefinitionMass(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return data.mass
end

function getItemDefinitionVolume(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return data.volume
end

function isItemDefinitionDivisible(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return data.tags["divisible"] or false
end

function getItemDefinitionDataTypes(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return deepcopy(data.data_types)
end

function getItemDefinitionDefaultData(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return deepcopy(data.data_default)
end

function getItemDefinitionWeaponInfo(definition)
	local id = type(definition) == "table" and definition.id or definition
	local data = ItemDefinitions[id]
	if (data == nil) then
		invalid_call("Invalid item definition.")
		return nil
	end
	return deepcopy(data.weapon)
end

function doItemDefinitionToString(definition)
	return "{ItemDefinition:" .. definition.id .. "}"
end

ItemDefinition = {
	getId = getItemDefinitionId,
	getName = getItemDefinitionName,
	getLocalizedName = getItemDefinitionLocalizedName,
	getMass = getItemDefinitionMass,
	getVolume = getItemDefinitionVolume,
	isDivisible = isItemDefinitionDivisible,
	getDataTypes = getItemDefinitionDataTypes,
	getDefaultData = getItemDefinitionDataTypes,
	getWeaponInfo = getItemDefinitionWeaponInfo,
	__tostring = doItemDefinitionToString
}
ItemDefinition.__index = ItemDefinition


function reloadItemDefinitions()
	local xmlRoot = XML.load("itemdefinitions_shared.xml")
	if (xmlRoot:getName() ~= "items") then
		outputDebugString("Invalid root node in itemdefinitions_shared.xml.", 1)
		return
	end

	ItemDefinitions = {}
	for _, node in ipairs(xmlRoot:getChildren()) do
		if (node:getName() == "item") then
			-- read attributes of item tag
			local id = node:getAttribute("id")
			local name = node:getAttribute("name")
			local mass = node:getAttribute("mass")
			local volume = node:getAttribute("volume")
			local tags = node:getAttribute("tags")

			-- interpret attributes
			---- id
			id = tonumber(id)
			---- name
			if (name == false) then
				name = nil
			end
			---- mass
			if (mass == false) then
				mass = 1
			else
				mass = tonumber(mass)
			end
			---- volume
			volume = tonumber(volume)
			---- tags
			tags = tags or ""

			-- check for invalid attributes
			local valid = true
			if (id == nil) then valid = false end
			if (mass == nil) then valid = false end
			if (volume == nil) then valid = false end
			if (tags == nil) then valid = false end

			if (not valid or ItemDefinitions[id] ~= nil) then
				outputDebugString("Skip item in itemdefinitions_shared.xml: " .. tostring(id), 1)
			else
				-- create item definition
				local definition = {
					["id"]=id,
					["name"]=name,
					["mass"]=mass,
					["volume"]=volume,
					["tags"]={},
					["localisations"]={},
					["data_types"]={}
				}
				for tag in tags:gmatch("[^%s,]+") do
					definition.tags[tag] = true
				end
				for _, itemnode in ipairs(node:getChildren()) do
					if (itemnode:getName() == "desc") then
						local dname = itemnode:getAttribute("name")
						local dlang = itemnode:getAttribute("lang")
						if (dname == false) then
							outputDebugString("Invalid 'desc'-tag for item '" .. tostring(id) .. "'.", 1)
						else
							if (dlang == false) then
								definition["name"] = dname
							else
								definition["localisations"][dlang] = dname
							end
						end
					elseif (itemnode:getName() == "weapon") then
						local weaponId = tonumber(itemnode:getAttribute("id"))
						local weaponType = itemnode:getAttribute("type") or "default"
						if (weaponId == nil) then
							outputDebugString("Invalid 'weapon'-tag for item '" .. tostring(id) .. "'.", 2)
						elseif (definition["weapon"] ~= nil) then
							outputDebugString("Multiple 'weapon'-tags for item '" .. tostring(id) .. "'.", 2)
						else
							definition["weapon"] = {
								["id"] = weaponId,
								["type"] = weaponType
							}
						end
					elseif (itemnode:getName() == "data") then
						local dataName = itemnode:getAttribute("name")
						local dataType = itemnode:getAttribute("type")
						local dataValue = itemnode:getAttribute("value")
						if (dataValue == false) then
							dataValue = nil
						else
							dataValue = convertToType(dataValue, dataType)
							if (dataValue == nil) then
								outputDebugString("Invalid value for 'data'-tag of item '" .. tostring(id) .. "'.", 2)
							end
						end
						if (dataName == false or dataType == false) then
							outputDebugString("Invalid 'data'-tag for item '" .. tostring(id) .. "'.", 2)
						elseif (definition.tags.divisible) then
							outputDebugString("'data'-tag is not allowed for divisible items: " .. tostring(id), 2)
						else
							definition.data_types[dataName] = dataType
							if (definition.data_default == nil) then
								definition.data_default = {}
							end
							definition.data_default[dataName] = dataValue
						end
					else
						outputDebugString("Invalid tag in itemdefinitions_shared.xml: " .. tostring(itemnode:getName()), 2)
					end
				end
				ItemDefinitions[id] = definition
			end
		else
			outputDebugString("Invalid tag in itemdefinitions_shared.xml: " .. tostring(node:getName()), 2)
		end
	end

	-- TODO xmlRoot:unload()
	xmlUnloadFile(xmlRoot)
end
addEventHandler("onResourceStart", resourceRoot, reloadItemDefinitions, false, "high+1")
addEventHandler("onClientResourceStart", resourceRoot, reloadItemDefinitions, false, "high+1")

function convertToType(value, valueType)
	if (value == false) then
		return nil
	elseif (valueType == "number") then
		return tonumber(value) or nil
	elseif (valueType == "string") then
		return value or nil
	elseif (valueType == "boolean") then
		if (value == "true" or value == "1") then
			return true
		elseif (value == "false" or value == "0") then
			return false
		else
			return nil
		end
	elseif (valueType == "table") then
		return fromJSON(value) or nil
	end
end
