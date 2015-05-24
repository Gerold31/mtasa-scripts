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
	return data.weight
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
	return data.divisible
end

function doItemDefinitionToString(definition)
	return "{ItemDefinition:" .. definition.id .. "}"
end

ItemDefinition = {
	getId = getItemDefinitionId,
	getName = getItemDefinitionName,
	getLocalizedName = getItemDefinitionLocalizedName,
	getWeight = getItemDefinitionWeight,
	getVolume = getItemDefinitionVolume,
	isDivisible = isItemDefinitionDivisible,
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
			local weight = node:getAttribute("weight")
			local volume = node:getAttribute("volume")
			local divisible = node:getAttribute("divisible")

			-- interpret attributes
			---- id
			id = tonumber(id)
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
			elseif (divisible == "true") then
				divisible = true
			else
				divisible = nil
			end

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
