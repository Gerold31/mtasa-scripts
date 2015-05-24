
function addInventory(element, key, volume)
	return addInventory1(element, key, volume)
end

function removeInventory(inventory, key)
	if (key ~= nil) then
		inventory = getInventory(inventory, key)
	end
	return removeInventory1(inventory)
end

function setInventoryItems(inventory, items)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	return setItems1(inventory, items)
end

function setInventoryItemAmount(inventory, itemdef, amount)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	return setItemAmount1(inventory, itemdef, amount)
end

function addInventoryItem(inventory, itemdef, amount)
	amount = amount or 1
	if (amount < 0) then return false end
	amount = getInventoryItemAmount(inventory, itemdef) + amount

	return setInventoryItemAmount(inventory, itemdef, amount)
end

function removeInventoryItem(inventory, itemdef, amount)
	amount = amount or 1
	if (amount < 0) then return false end
	amount = getInventoryItemAmount(inventory, itemdef) - amount

	return setInventoryItemAmount(inventory, itemdef, amount)
end

function moveInventoryItem(from, to, itemdef, amount)
	amount = amount or 1
	if (canInventoryItemMove(from, to, itemdef, amount)) then
		assert(removeInventoryItem(from, itemdef, amount))
		assert(addInventoryItem(to, itemdef, amount))
		return true
	else
		return false
	end
end


if (Inventory == nil) then Inventory = {} end
Inventory.remove = removeInventory
Inventory.setItems = setInventoryItems
Inventory.setItemAmount = setInventoryItemAmount
Inventory.addItem = addInventoryItem
Inventory.removeItem = removeInventoryItem
Inventory.moveItem = moveInventoryItem


-- source: inventory.element
-- onInventoryOpen(client, inventory)
addEvent("onInventoryOpen")
-- source: inventory.element
-- onInventoryClose(client, inventory)
addEvent("onInventoryClose")
-- source: inventory.element
-- onInventorySetItemAmount(inventory, itemdef, amount)
addEvent("onInventorySetItemAmount")
-- source: inventory.element
-- onInventorySetItems(inventory)
addEvent("onInventorySetItems")
-- source: inventory.element
-- onInventoryMoveItem(client, from, to, itemdef, amount, userdata)
addEvent("onInventoryMoveItem")
-- source: root
-- onInventoryStartup()
addEvent("onInventoryStartup")
-- source: root
-- onInventoryShutdown()
addEvent("onInventoryShutdown")
