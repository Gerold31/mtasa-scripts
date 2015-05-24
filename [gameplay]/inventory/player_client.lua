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
		closeInventory(d.inventory)
		d.inventory = nil
	end, false, "low"
)

addEventHandler("onClientInventoryClose", getLocalPlayer(),
	function()
		assert(openInventory(getLocalPlayer(), "main"))
	end, false
)
