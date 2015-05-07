local inventory = {}
local vehicleInventory = nil
local inventoryWindow = nil
local itemList = nil
local itemCol = nil
local amountCol = nil

addEvent("onClientInventoryChange", true)
addEvent("onClientVehicleInventoryChange", true)

bindKey("i", "up", "inventory")

function createInventory()
	local X = 0.375
	local Y = 0.375
	local Width = 0.25
	local Height = 0.25
	inventoryWindow = guiCreateWindow(X, Y, Width, Height, "Inventory", true)
	guiSetVisible(inventoryWindow, false)


	itemList = guiCreateGridList(0, 0.1, 1, .9, true, inventoryWindow)
	itemCol = guiGridListAddColumn(itemList, "Item", 0.5)
	amountCol = guiGridListAddColumn(itemList, "Amount", 0.2)

	updateItemList();
end

function updateItemList()
	guiGridListClear(itemList)
	for item, amount in pairs(inventory.items) do
		local row = guiGridListAddRow(itemList)
		guiGridListSetItemText(itemList, row, itemCol, items[item].name, false, false )
		guiGridListSetItemText(itemList, row, amountCol, amount, false, false )
	end
end

function toggleInventory(player, command)
	local toggle = not guiGetVisible(inventoryWindow);
	if(toggle) then
		updateItemList();
	end
	guiSetVisible(inventoryWindow, toggle)
	showCursor(toggle)
	--guiSetInputEnabled(toggle)
end
addCommandHandler("inventory", toggleInventory)

addEventHandler("onClientResourceStart", getRootElement(), function() createInventory() end)

addEventHandler("onClientInventoryChange", getRootElement(),
	function (inv)
		inventory = inv
	end
)

addEventHandler("onClientVehicleInventoryChange", getRootElement(),
	function (inv)
		vehicleInventory = inv
	end
)
