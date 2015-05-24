-- Hints:
--   * ´getInventory´ and ´getInvetories´ only knows open invetories.
--   * You must not close an inventory before ´onClientInventoryOpen´ runs.
--   * ´onClientInventoryOpen´ does not run again if the inventory is already open
--   * ´onClientInventoryClose´ can run without running of ´onClientInventoryOpen´ before.
--     It means that the server rejected the request.
--   * ´onClientInventoryClose´ can run without calling of ´closeInventory´.
--     It means that the server has closed the inventory for you.
-- Inventories[element][key]:
--   * ´items´ and ´volume´ are nil until server sends the data
--   * ´openCount´ saves how often the inventory was opend


function openInventory(element, key)
	if (Inventories[element] == nil) then
		Inventories[element] = {}
		addEventHandler("onClientElementDestroy", element, onClientElementDestroy, false, "high+100")
	end

	if (Inventories[element][key] ~= nil) then
		Inventories[element][key].openCount = Inventories[element][key].openCount + 1
	else
		Inventories[element][key] = {
			["owner"] = element,
			["key"] = key,
			["openCount"] = 1
		}
		triggerServerEvent("serverInventoryOpen", element, key)
	end
	return setmetatable({["element"] = element, ["key"] = key}, Inventory)
end

function closeInventory(inventory)
	local element = inventory.element
	local inv = getInv(inventory)

	if (inv == nil) then return end
	inv.openCount = inv.openCount - 1

	if (inv.openCount == 0) then
		triggerServerEvent("serverInventoryClose", element, key)
		triggerEvent("onClientInventoryClose", element, inventory)
		removeInventory(inventory)
	end
end

function moveInventoryItem(from, to, itemdef, amount, userdata)
	amount = amount or 1
	triggerServerEvent("serverInventoryMoveItem", from.element, from.key, to.element, to.key, getItemDefinitionId(itemdef), amount, userdata)
end


if (Inventory == nil) then Inventory = {} end
Inventory.close = closeInventory
Inventory.moveItem = moveInventoryItem


-- source: inventory.element
-- onClientInventoryOpen(inventory)
addEvent("onClientInventoryOpen")
-- source: inventory.element
-- onClientInventoryClose(inventory)
addEvent("onClientInventoryClose")
-- source: inventory.element
-- onClientInventoryUpdate(inventory)
addEvent("onClientInventoryUpdate")
-- source: inventory.element
-- onClientInventorySetItemAmount(inventory, itemdef, amount)
addEvent("onClientInventorySetItemAmount")
-- source: inventory.element
-- onClientInventorySetItems(inventory)
addEvent("onClientInventorySetItems")
-- source: root
-- onClientInventoryStartup()
addEvent("onClientInventoryStartup")
-- source: root
-- onClientInventoryShutdown()
addEvent("onClientInventoryShutdown")

-- source: inventory.element
-- clientInventoryOpen(key, inventory_data) [data with items]
addEvent("clientInventoryOpen", true)
-- source: inventory.element
-- clientInventoryClose(key)
addEvent("clientInventoryClose", true)
-- source: inventory.element
-- clientInventoryUpdate(key, inventory_data) [data without items]
addEvent("clientInventoryUpdate", true)
-- source: inventory.element
-- clientInventorySetItemAmount(key, definitionId, amount)
addEvent("clientInventorySetItemAmount", true)
-- source: inventory.element
-- clientInventorySetItemAmount(key, items)
addEvent("clientInventorySetItems", true)


function clientInventoryOpen(key, inventory_data)
	local inventory = getInventory(source, key)
	local inv = getInv(inventory)
	if (inv == nil) then return end
	inv.volume = inventory_data.volume
	inv.items = {}
	setItems(inventory, inventory_data.items)
	triggerEvent("onClientInventoryOpen", source, inventory)
end
addEventHandler("clientInventoryOpen", root, clientInventoryOpen)

function clientInventoryClose(key)
	local inv = getInv(source, key)
	if (inv == nil) then return end
	local inventory = getInventory(source, key)
	triggerEvent("onClientInventoryClose", source, inventory)
	removeInventory(inventory)
end
addEventHandler("clientInventoryClose", root, clientInventoryClose)

function clientInventoryUpdate(key, inventory_data)
	local inv = getInv(source, key)
	if (inv == nil) then return end
	inv.volume = inventory_data.volume
	triggerEvent("onClientInventoryUpdate", source, getInventory(source, key))
end
addEventHandler("clientInventoryUpdate", root, clientInventoryUpdate)

function clientInventorySetItemAmount(key, definitionId, amount)
	local itemdef = getItemDefinition(definitionId)
	local inventory = getInventory(element, key)
	if (isInventoryReady(inventory)) then
		assert(setItemAmount(inventory, itemdef, amount))
		triggerEvent("onClientInventorySetItemAmount", source, inventory, itemdef, amount)
	end
end
addEventHandler("clientInventorySetItemAmount", root, clientInventorySetItemAmount)

function clientInventorySetItems(key, definitionId, amount)
	local inventory = getInventory(element, key)
	if (isInventoryReady(inventory)) then
		assert(setItems(inventory, items))
		triggerEvent("onClientInventorySetItems", source, inventory)
	end
end
addEventHandler("clientInventorySetItems", root, clientInventorySetItems)

function onClientElementDestroy()
	for key, inv in pairs(Inventories[source]) do
		triggerEvent("onClientInventoryClose", source, assert(getInventory(source, key)))
	end
	Inventories[source] = nil
end

function removeInventory(inventory)
	local element = inventory.element
	local key = inventory.key
	Inventories[element][key] = nil
	if (next(Inventories[element]) == nil) then
		Inventories[element] = nil
		removeEventHandler("onClientElementDestroy", element, onClientElementDestroy)
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerEvent("onClientInventoryStartup", root)
	end, false
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		triggerEvent("onClientInventoryShutdown", root)
	end, false
)
