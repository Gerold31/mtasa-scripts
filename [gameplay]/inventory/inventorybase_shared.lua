-- Inventories[element][key]:
--   * ´owner´ saves the element where the inventory is attched to
--   * ´key´ saves the key of the inventory
--   * ´volume´ saves the amount of space in the inventory
--   * ´items´ saves the items in the inventory
--   * the keys of ´items´ are the ids of the item-definition
--   * the values in ´items´ are tables like {type=itemdef, amount=n, userdata={}}


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
			["userdata"] = deepcopy(stack.userdata)
		})
	end
	return items
end

function setItems0(inv, items)
	if (type(items) ~= "table") then return false end
	if (not isReady0(inv)) then return false end

	inv.items = {}
	for _, stack in pairs(items) do
		local itemdef = getItemDefinition(stack.type)
		if (itemdef == nil) then
			invalid_call("Invalid item definition in items. Ignoring them.")
		else
			inv.items[stack.type] = {
				["type"] = itemdef,
				["amount"] = stack.amount,
				["userdata"] = {}
			}
			for key, data in pairs(stack.userdata) do
				if (type(key) == "number" and key <= amount) then
					inv.items[defId].userdata[key] = data
				end
			end
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

	if (amount > 0 and inv.items[defId] == nil) then
		inv.items[defId] = {
			["type"] = itemdef,
			["amount"] = amount,
			["userdata"] = {}
		}
		return true
	end
	if (amount > 0 and inv.items[defId] ~= nil) then
		inv.items[defId].amount = amount
		for key, _ in pairs(inv.items[defId].userdata) do
			if (key > amount) then
				inv.items[defId].userdata[key] = nil
			end
		end
		return true
	end
	if (amount == 0 and inv.items[defId] ~= nil) then
		inv.items[defId] = nil
		return true
	end
end

function canItemMove0(from, to, itemdef, amount)
	if (not isReady0(from) or not isReady0(to) or not itemdef or not amount or amount < 0) then
		return false
	end
	if (getItemAmount0(from, itemdef) < amount) then
		return false
	end
	return true
end

function moveItem0(from, to, itemdef, amount)
	if (not canItemMove0(from, to, itemdef, amount)) then
		return false
	end
	local fOffset = getItemAmount0(from) - amount
	local tOffset = getItemAmount0(to)
	assert(setItemAmount0(to, itemdef, getItemAmount0(to, itemdef) + amount))
	for key, data in pairs(from[defId].userdata) do
		if (key > fOffset) then
			to[defId].userdata[tOffset + key - fOffset] = data
		end
	end
	assert(setItemAmount0(from, itemdef, getItemAmount0(from, itemdef) - amount))
end
