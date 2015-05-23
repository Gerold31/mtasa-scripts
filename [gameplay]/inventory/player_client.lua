local inventory = nil

function getPlayerInventory()
	return inventory
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		inventory = assert(openInventory(getLocalPlayer(), "main"))
	end, false, "high"
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		closeInventory(inventory)
		inventory = nil
	end, false, "low"
)

addEventHandler("onClientInventoryClose", getLocalPlayer(),
	function()
		assert(openInventory(getLocalPlayer(), "main"))
	end, false
)
