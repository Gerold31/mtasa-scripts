local d = {}
d.inventory = nil
d.otherInventory = nil
d.inventoryView = nil
d.otherView = nil


function onOpen(inventory)
	if (not d.inventoryView.window:getVisible()) then return end
	if (source == d.inventory.element) then
		reloadItemList(d.inventoryView, d.inventory)
	end
	if (d.otherInventory ~= nil and source == d.otherInventory.element) then
		reloadItemList(d.otherView, d.otherInventory)
	end
end

function onClose(inventory)
	if (not d.inventoryView.window:getVisible()) then return end
	if (source == d.inventory.element) then
		reloadItemList(d.inventoryView, d.inventory)
	end
end

function onSetItemAmount(inventory, itemdef, amount)
	if (not d.inventoryView.window:getVisible()) then return end
	-- TODO
end

function onSetItems(inventory)
	if (not d.inventoryView.window:getVisible()) then return end
	if (source == d.inventory.element) then
		reloadItemList(d.inventoryView, d.inventory)
	end
	if (d.otherInventory ~= nil and source == d.otherInventory.element) then
		reloadItemList(d.otherView, d.otherInventory)
	end
end

function createOtherView(name, element, key)
	d.otherView = createView(name)
	d.otherInventory = openInventory(element, key)
	d.inventoryView.window:setPosition(0.3, 0.25, true)
	d.otherView.window:setPosition(0.55, 0.25, true)

	addEventHandler("onClientInventoryOpen", element, onOpen)
	addEventHandler("onClientInventoryClose", element, onClose)
	addEventHandler("onClientInventorySetItemAmount", element, onSetItemAmount)
	addEventHandler("onClientInventorySetItems", element, onSetItems)

	if (d.inventoryView.window:getVisible()) then
		reloadItemList(d.otherView, d.otherInventory)
		d.otherView.window:setVisible(true)
	end
end

addEventHandler("onClientPlayerVehicleEnter", getLocalPlayer(),
	function (vehicle)
		createOtherView("Vehicle", vehicle, "main")
	end, false
)

function destroyotherView()
	local vehicle = d.otherInventory.element

	d.otherView.window:destroy()
	d.otherView = nil
	closeInventory(d.otherInventory)
	d.otherInventory = nil
	d.inventoryView.window:setPosition(0.425, 0.25, true)

	removeEventHandler("onClientInventoryOpen", vehicle, onOpen)
	removeEventHandler("onClientInventoryClose", vehicle, onClose)
	removeEventHandler("onClientInventorySetItemAmount", vehicle, onSetItemAmount)
	removeEventHandler("onClientInventorySetItems", vehicle, onSetItems)
end
addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(), destroyotherView, false)

function createView(name)
	local view = {}

	view.window = GuiWindow(0, 0, 0.15, 0.5, name, true)
	view.window:setVisible(false)

	view.list = GuiGridList(0, 0.1, 1, .9, true, view.window)
	view.col_item = view.list:addColumn("Item", 0.7)
	view.col_amou = view.list:addColumn("Amount", 0.2)

	return view
end

function reloadItemList(view, inventory)
	view.list:clear()
	if (isInventoryReady(inventory)) then
		for _, stack in pairs(getInventoryItems(inventory)) do
			local row = view.list:addRow()
			local name = getItemDefinitionLocalizedName(stack.type)
			view.list:setItemText(row, view.col_item, name, false, false)
			view.list:setItemText(row, view.col_amou, stack.amount, false, false)
		end
	else
		local row = view.list:addRow()
		local name = "Inventory not ready yet."
		view.list:setItemText(row, view.col_item, name, false, false)
		--view.list:setItemText(row, view.col_amou, stack.amount, false, false)
	end
end

function updateItemList(view, itemdef, amount)
end

function toggleInventory()
	local toggle = not d.inventoryView.window:getVisible();
	if(toggle) then
		reloadItemList(d.inventoryView, d.inventory);
		if (d.otherView ~= nil) then
			reloadItemList(d.otherView, d.otherInventory)
		end
	end

	d.inventoryView.window:setVisible(toggle)
	if (d.otherView ~= nil) then
		d.otherView.window:setVisible(toggle)
	end

	if (toggle) then
		--guiSetInputMode("no_binds_when_editing")
	else
		--guiSetInputMode("allow_binds")
	end
	showCursor(toggle)
	-- guiSetInputEnabled(toggle)
end
bindKey("i", "up", toggleInventory)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		d.inventory = getPlayerInventory()
		d.inventoryView = createView("Inventory")
		d.inventoryView.window:setPosition(0.425, 0.25, true)

		local player = getLocalPlayer()
		addEventHandler("onClientInventoryOpen", player, onOpen)
		addEventHandler("onClientInventoryClose", player, onClose)
		addEventHandler("onClientInventorySetItemAmount", player, onSetItemAmount)
		addEventHandler("onClientInventorySetItems", player, onSetItems)

		local vehicle = player:getOccupiedVehicle()
		if (vehicle) then
			createOtherView("Vehicle", vehicle, "main")
		end
	end, false
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		if (d.otherView ~= nil) then
			destroyotherView()
		end

		local player = getLocalPlayer()
		removeEventHandler("onClientInventoryOpen", player, onOpen)
		removeEventHandler("onClientInventoryClose", player, onClose)
		removeEventHandler("onClientInventorySetItemAmount", player, onSetItemAmount)
		removeEventHandler("onClientInventorySetItems", player, onSetItems)

		d.inventory = nil
		d.inventoryView.window:destroy()
		d.inventoryView = nil
	end, false
)
