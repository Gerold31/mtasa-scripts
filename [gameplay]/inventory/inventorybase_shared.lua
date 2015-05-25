-- Inventories[element][key]:
--   * ´owner´ saves the element where the inventory is attched to
--   * ´key´ saves the key of the inventory
--   * ´volume´ saves the amount of space in the inventory
--   * ´items´ saves the items in the inventory
--   * the keys of ´items´ are the ids of the item-definition
--   * the values in ´items´ are tables like {type=itemdef, amount=n, data={}}


Inventories = {}

function getInv0(element, key)
	if (element == nil) then return nil end
	if (key == nil) then
		key = element.key
		element = element.element
	end

	if (Inventories[element] == nil) then
		return nil
	else
		return Inventories[element][key]
	end
end

function isReady0(inv)
	if (inv ~= nil and inv.items ~= nil) then
		return true
	else
		return false
	end
end

function getItems0(inv)
	if (not isReady0(inv)) then return nil end

	local items = {}
	for defId, stack in pairs(inv.items) do
		table.insert(items, {
			["type"] = defId,
			["amount"] = stack.amount,
			["data"] = deepcopy(stack.data)
		})
	end
	return items
end

function setItems0(inv, items)
	if (type(items) ~= "table") then return false end
	if (not isReady0(inv)) then return false end

	inv.items = {}
	for _, stack in pairs(items) do
		local defId = stack.type
		local itemdef = getItemDefinition(stack.type)
		local defaultData = getItemDefinitionDefaultData(itemdef)
		if (itemdef == nil) then
			invalid_call("Invalid item definition in items. Ignoring them.")
		elseif (defaultData == nil or stack.data == nil) then
			local amount = stack.amount
			if (type(amount) ~= "number" or amount < 0) then
				invalid_call("Invalid amount in items. Ignoring them.")
			elseif (amount > 0) then
				inv.items[defId] = {
					["type"] = itemdef,
					["amount"] = amount
				}
				if (defaultData ~= nil) then
					inv.items[defId].data = {}
					for i = 1, amount do
						table.insert(inv.items[defId].data, defaultData)
					end
				end
			end
		else
			inv.items[defId] = {
				["type"] = itemdef,
				["data"] = {}
			}
			for _, data in ipairs(stack.data) do
				table.insert(inv.items[defId].data, defaultData)
				setItemData0(inv, itemdef, #inv.items[defId].data, data)
			end
			inv.items[defId].amount = #inv.items[defId].data
		end
	end

	return true
end

function getItemAmount0(inv, itemdef)
	local defId = getItemDefinitionId(itemdef)

	if (not isReady0(inv) or inv.items[defId] == nil) then return 0 end
	return inv.items[defId].amount
end

function setItemAmount0(inv, itemdef, amount)
	local defId = getItemDefinitionId(itemdef)
	if (not isReady0(inv)) then return false end
	if (amount < 0) then return false end

	local defaultData = getItemDefinitionDefaultData(itemdef)
	if (amount > 0 and inv.items[defId] == nil) then
		inv.items[defId] = {
			["type"] = itemdef,
			["amount"] = amount
		}
		if (defaultData ~= nil) then
			inv.items[defId].data = {}
			for i = 1, amount do
				table.insert(inv.items[defId].data, defaultData)
			end
		end
		return true
	end
	if (amount > 0 and inv.items[defId] ~= nil) then
		inv.items[defId].amount = amount
		if (defaultData ~= nil) then
			local diff = amount - inv.items[defId].amount
			if (diff > 0) then
				for i = 1, diff do
					table.insert(inv.items[defId].data, defaultData)
				end
			elseif (diff < 0) then
				for i = 1, -diff do
					table.remove(inv.items[defId].data)
				end
			end
		end
		return true
	end
	if (amount == 0 and inv.items[defId] ~= nil) then
		inv.items[defId] = nil
		return true
	end
end

function addItems0(inv, itemdef, data)
	local defId = getItemDefinitionId(itemdef)
	if (not isReady0(inv)) then return false end

	if (type(data) == "number") then
		if (data < 0) then
			return false
		end
		return setItemAmount0(inv, itemdef, getItemAmount0(inv, itemdef) + data)
	end

	local defaultData = getItemDefinitionDefaultData(itemdef)
	if (inv.items[defId] == nil) then
		inv.items[defId] = {
			["type"] = itemdef,
			["amount"] = 0
		}
		if (defaultData ~= nil) then
			inv.items[defId].data = {}
		end
	end
	for _, itemdata in ipairs(data) do
		inv.items[defId].amount = inv.items[defId].amount + 1
		if (defaultData ~= nil) then
			table.insert(inv.items[defId].data, defaultData)
			setItemData0(inv, itemdef, #inv.items[defId].data, itemdata)
		end
	end
	return true
end

function removeItems0(inv, itemdef, pos)
	local defId = getItemDefinitionId(itemdef)
	if (not isReady0(inv)) then return false end

	if (type(pos) ~= "number") then
		for _, itempos in ipairs(pos) do
			if (itempos > inv.items[defId].amount) then
				return false
			end
		end
	end

	local defaultData = getItemDefinitionDefaultData(itemdef)
	if (defaultData == nil) then
		if (type(pos) ~= "number") then
			pos = #pos
		end
		if (pos < 0) then
			return false
		end
		if (setItemAmount0(inv, itemdef, getItemAmount0(inv, itemdef) - pos)) then
			return pos
		else
			return false
		end
	end

	assert(inv.items[defId].amount == #inv.items[defId].data)

	local ret = {}
	if (type(pos) == "number") then
		for i = 1, pos do
			table.insert(ret, table.remove(inv.items[defId].data))
		end
	else
		table.sort(pos,
			function (w1,w2)
				if w1 > w2 then return true end
			end
		)
		for _, itempos in ipairs(pos) do
			if (itempos <= #inv.items[defId].data) then
				table.insert(ret, table.remove(inv.items[defId].data, itempos))
			end
		end
	end
	inv.items[defId].amount = #inv.items[defId].data
	return ret
end

function canItemsMove0(from, to, itemdef, amount)
	if (not isReady0(from) or not isReady0(to) or not itemdef or not amount) then
		return false
	end
	if (type(amount) == "number" and amount < 0) then
		return false
	end
	local fromAmount = getItemAmount0(from, itemdef)
	if (type(amount) == "table") then
		for _, pos in ipairs(amount) do
			if (pos > fromAmount or pos < 1) then
				return false
			end
		end
	end
	if (fromAmount < amount) then
		return false
	end
	return true
end

function moveItems0(from, to, itemdef, amount)
	if (not canItemsMove0(from, to, itemdef, amount)) then
		return false
	end
	assert(addItems0(to, itemdef, assert(removeItems0(from, itemdef, amount)) ))
end

function setItemData0(inv, itemdef, pos, data)
	local defId = getItemDefinitionId(itemdef)
	if (inv.items[defId] == nil) then
		invalid_call("There are no items of this type: " .. tostring(defId))
		return false
	end
	if (pos < 1 or pos > #inv.items[defId].data) then
		invalid_call("Invalid index of item data.")
		return false
	end
	local dataTypes = getItemDefinitionDataTypes(itemdef)
	local itemdata = inv.items[defId].data[pos]
	for key, value in pairs(data) do
		if (type(value) == dataTypes[key]) then
			itemdata[key] = value
		else
			invalid_call("Invalid data for item: " .. tostring(defId))
		end
	end
end

function getItemData0(inv, itemdef, pos)
	local defId = getItemDefinitionId(itemdef)
	if (inv.items[defId] == nil) then
		invalid_call("There are no items of this type: " .. tostring(defId))
		return false
	end
	if (pos < 1 or pos > #inv.items[defId].data) then
		invalid_call("Invalid index of item data.")
		return false
	end
	return inv.items[defId].data[pos]
end
