function loadPlayerInventory(player, account)
	local inventory = assert(addInventory(player, "main", 100))
	local data = account:getData("inventory_main")
	if (data) then
		assert(setInventoryItems(inventory, fromJSON(data)))
	end
end

function savePlayerInventory(player, account, remove)
	remove = remove or true
	local inventory = getInventory(player, "main")
	assert(account:setData("inventory_main", toJSON(getInventoryItems(inventory))))
	if (remove) then
		assert(removeInventory(inventory))
	end
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		for _, player in pairs(getElementsByType('player')) do
			loadPlayerInventory(player, player:getAccount())
		end
	end, false, "high"
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for _, player in pairs(getElementsByType('player')) do
			savePlayerInventory(player, player:getAccount(), false)
		end
	end, false, "low"
)

addEventHandler("onPlayerJoin", root,
	function()
		loadPlayerInventory(source, source:getAccount())
	end
)

addEventHandler("onPlayerLogin", root,
	function(prevAcc, newAcc)
		savePlayerInventory(source, prevAcc)
		loadPlayerInventory(source, newAcc)
	end
)

addEventHandler("onPlayerLogout", root,
	function(prevAcc, newAcc)
		savePlayerInventory(source, prevAcc)
		loadPlayerInventory(source, newAcc)
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		savePlayerInventory(source, source:getAccount())
	end
)


function onInventoryChange(inventory)
	local owner = inventory.owner
	if(inventory.type == "player") then
		triggerClientEvent(owner, "onClientInventoryChange", owner, inventory)
	elseif(inventory.type == "vehicle" and getVehicleOccupants(owner)) then
		for _, occupant in pairs(getVehicleOccupants(owner)) do
			if(occupant and getElementType(occupant) == "player") then
				triggerClientEvent(occupant, "onClientVehicleInventoryChange", occupant, inventory)
			end
		end
	end
end

-- @todo clean up

-- debugging
function take(player, command, item, amount)
	if(not (item and amount)) then
		outputChatBox("Wrong syntax, use /take <item> <amount>", player)
	end

	local vehicleInventory = inventories[getPedOccupiedVehicle(player)]

	if(not moveItem(vehicleInventory, inventories[player], getItemFromName(item), tonumber(amount))) then
		outputChatBox("failed", player)
	end
end
-- addCommandHandler("take", take)

function give(player, command, item, amount)
	if(not (item and amount)) then
		outputChatBox("Wrong syntax, use /give <item> <amount>", player)
	end

	local vehicleInventory = inventories[getPedOccupiedVehicle(player)]

	if(not moveItem(inventories[player], vehicleInventory, getItemFromName(item), tonumber(amount))) then
		outputChatBox("failed", player)
	end
end
-- addCommandHandler("give", give)
