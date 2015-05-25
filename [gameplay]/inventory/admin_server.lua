addCommandHandler("additem",
	function (player, command, ...)
		local args = {...}
		if (player and (#args == 1 or #args == 2)) then
			local inventory = getInventory(player, "main")
			local itemdef = getItemDefinition(tonumber(args[1]))
			local amount = tonumber(args[2] or 1)
			if (not inventory) then
				outputChatBox("You don't have an inventory.", player, 255, 0, 0)
				return
			end
			if (not itemdef) then
				outputChatBox("Invalid item: " .. tostring(args[1]), player, 255, 255, 0)
				return
			end
			if (not amount) then
				outputChatBox("Invalid amount: " .. tostring(args[2]), player, 255, 255, 0)
				return
			end
			if (addInventoryItem(inventory, itemdef, amount)) then
				local name = getItemDefinitionName(itemdef)
				outputChatBox("Success. " .. name .. ": " .. tostring(getInventoryItemAmount(inventory, itemdef)), player, 0, 255, 0)
				return
			else
				outputChatBox("Failure.", player, 255, 0, 0)
				return
			end
		end
		outputChatBox("Usage: /additem <item> [amount]", player, 255, 255, 0)
	end, true
)

addCommandHandler("additemvehicle",
	function (player, command, ...)
		local args = {...}
		local vehicle = getPedOccupiedVehicle(player)
		if (player and (#args == 1 or #args == 2) and vehicle) then
			local inventory = getInventory(vehicle, "main")
			local itemdef = getItemDefinition(tonumber(args[1]))
			local amount = tonumber(args[2] or 1)
			if (not inventory) then
				outputChatBox("The vehicle doesn't have a vehicle", player, 255, 0, 0)
				return
			end
			if (not itemdef) then
				outputChatBox("Invalid item: " .. tostring(args[1]), player, 255, 255, 0)
				return
			end
			if (not amount) then
				outputChatBox("Invalid amount: " .. tostring(args[2]), player, 255, 255, 0)
				return
			end
			if (addInventoryItem(inventory, itemdef, amount)) then
				local name = getItemDefinitionName(itemdef)
				outputChatBox("Success. " .. name .. ": " .. tostring(getInventoryItemAmount(inventory, itemdef)), player, 0, 255, 0)
				return
			else
				outputChatBox("Failure.", player, 255, 0, 0)
				return
			end
		end
		outputChatBox("Usage: /additemvehicle <item> [amount]", player, 255, 255, 0)
	end, true
)
