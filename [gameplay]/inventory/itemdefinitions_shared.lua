ItemDefinitions = {}

function getItemDefinition(id)
	local definition = ItemDefinitions[id]
	if (definition == nil) then
		outputDebugString("Request invalid item-definition: " .. tostring(id), 2)
	end
	return definition
end

function getItemDefinitionId(definition)
	return definition.id
end

function getItemDefinitionName(definition)
	return definition.name
end

function getItemDefinitionLocalizedName(definition, lang)
	lang = lang or getLocalization().code
	local name = definition.localisations[lang]
	if (name == nil) then
		return definition.name
	else
		return name
	end
end

function getItemDefinitionWeight(definition)
	return definition.weight
end

function getItemDefinitionVolume(definition)
	return definition.volume
end

function isItemDefinitionDivisible(definition)
	return definition.divisible
end

function doItemDefinitionToString(definition)
	return definition.id
end

function doItemDefinitionWriteError(table, key, value)
	outputDebugString("You cannot write to a item-definition: [" .. tostring(key) .. "]=" .. tostring(value), 1)
end

ItemDefinition = {
	getId = getItemDefinitionId,
	getName = getItemDefinitionName,
	getLocalizedName = getItemDefinitionLocalizedName,
	getWeight = getItemDefinitionWeight,
	getVolume = getItemDefinitionVolume,
	isDivisible = isItemDefinitionDivisible
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
			local weight = node:getAttribute("weight")
			local volume = node:getAttribute("volume")
			local divisible = node:getAttribute("divisible")

			-- interpret attributes
			---- id
			if (id == false) then
				id = nil
			end
			---- name
			if (name == false) then
				name = nil
			end
			---- weight
			if (weight == false) then
				weight = 1
			else
				weight = tonumber(weight)
			end
			---- volume
			volume = tonumber(volume)
			---- divisible
			if (divisible == false or divisible == "false") then
				divisible = false
			else if (divisible == "true") then
				divisible = true
			else
				divisible = nil
			end end

			-- check for invalid attributes
			local valid = true
			if (id == nil) then valid = false end
			if (weight == nil) then valid = false end
			if (volume == nil) then valid = false end
			if (divisible == nil) then valid = false end

			if (not valid or ItemDefinitions[id] ~= nil) then
				outputDebugString("Skip item in itemdefinitions_shared.xml: " .. tostring(id), 1)
			else
				-- create item definition
				local definition = {
					["id"]=id,
					["name"]=name,
					["weight"]=weight,
					["volume"]=volume,
					["divisible"]=divisible,
					["localisations"]={}
				}
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
					else
						outputDebugString("Invalid tag in itemdefinitions_shared.xml: " .. tostring(itemnode:getName()), 2)
					end
				end
				setmetatable(definition, ItemDefinition)
				ItemDefinitions[id] = setmetatable({}, {
					__index = definition,
					__newindex = doItemDefinitionWriteError,
					__metatable = false,
					__tostring = doItemDefinitionToString,
					__call = getItemDefinition,
				})
			end
		else
			outputDebugString("Invalid tag in itemdefinitions_shared.xml: " .. tostring(node:getName()), 2)
		end
	end

	-- TODO xmlRoot:unload()
	xmlUnloadFile(xmlRoot)
end
addEventHandler("onResourceStart", resourceRoot, reloadItemDefinitions)
addEventHandler("onClientResourceStart", resourceRoot, reloadItemDefinitions)
