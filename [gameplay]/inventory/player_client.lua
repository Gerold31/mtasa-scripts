local d = {
	inventory = nil
}

function getPlayerInventory()
	return d.inventory
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		d.inventory = assert(openInventory(getLocalPlayer(), "main"))
	end, false, "high"
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		--closeInventory(d.inventory)
		d.inventory = nil
	end, false, "low"
)

addEventHandler("onClientInventoryClose", getLocalPlayer(),
	function()
		outputDebugString("Inventory of local player closed.", 3)
		assert(openInventory(source, "main"))
	end, false
)

addEventHandler("onClientInventoryOpen", getLocalPlayer(),
	function()
		outputDebugString("Inventory of local player opened.", 3)
	end, false
)
