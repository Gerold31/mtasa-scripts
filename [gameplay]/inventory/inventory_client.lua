-- Hints:
--   * ´getInventory´ and ´getInvetories´ only knows open invetories.
--   * You must not close an inventory before ´onClientInventoryOpen´ runs.
--   * ´onClientInventoryOpen´ does not run again if the inventory is already open
--   * ´onClientInventoryClose´ can run without running of ´onClientInventoryOpen´ before.
--     It means that the server rejected the request.
--   * ´onClientInventoryClose´ can run without calling of ´closeInventory´.
--     It means that the server has closed the inventory for you.


function openInventory(element, key)
	local inventory = getInventory(element, key)
	local inv = getInv0(inventory)
	if (inv == nil or inv.openCount == 0) then
		inventory = openInventory1(element, key)
		inv = getInv0(inventory)
	end
	inv.openCount = inv.openCount + 1
	return inventory
end

function closeInventory(inventory)
	local inv = getInv0(inventory)
	if (inv == nil) then return end

	inv.openCount = inv.openCount - 1
	if (inv.openCount == 0) then
		closeInventory1(inventory)
	end
end

function moveInventoryItem(from, to, itemdef, amount, userdata)
	amount = amount or 1
	moveInventoryItem1(from, to, itemdef, amount, userdata)
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
