function getPlayerInventory()
	return exports["inventory"]:getPlayerInventory()
end

function openInventory(element, key)
	return exports["inventory"]:openInventory(element, key)
end

function closeInventory(inventory)
	return exports["inventory"]:closeInventory(inventory)
end

function getInventoryItems(inventory)
	return exports["inventory"]:getInventoryItems(inventory)
end

function isInventoryReady(inventory)
	return exports["inventory"]:isInventoryReady(inventory)
end

function getItemDefinitionLocalizedName(itemdef)
	return exports["inventory"]:getItemDefinitionLocalizedName(itemdef)
end
