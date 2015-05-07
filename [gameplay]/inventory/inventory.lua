local inventories = {}


function onInventoryChange(inventory)
    local owner = inventory.owner
    if(inventory.type == "player") then
	triggerClientEvent(owner, "onClientInventoryChange", owner, inventory)
    elseif(inventory.type == "vehicle") then
	for _, occupant in pairs(getVehicleOccupants(owner)) do
	    if(occupant and getElementType(occupant) == "player") then
		triggerClientEvent(occupant, "onClientVehicleInventoryChange", occupant, inventory)
	    end
	end
    end
end

-- loads inventory from db
function loadPlayerInventory(player)
    -- @todo that's not a db
    inventories[player] = {volume=50, owner=player, type="player", items={water_bottle = 10}}

    -- workaround to make sure client has registerd his event handler first
    setTimer(onInventoryChange, 1000, 1, inventories[player])
end

-- loads inventory from db
function loadVehicleInventory(vehicle)
    -- @todo still not a db
    inventories[vehicle] = {volume=500, owner=vehicle, type="vehicle", items={tire = 5}}

    -- workaround to make sure client has registerd his event handler first
    setTimer(onInventoryChange, 1000, 1, inventories[vehicle])
end

function addItem(inventory, item, amount)
    if(not (inventory and item and amount)) then
	return false
    end

    if(getInventoryVolume(inventory) + amount * items[item].volume > inventory.volume) then
	return false
    end

    if(not inventory.items[item]) then
	inventory.items[item] = amount
    else
	inventory.items[item] = inventory.items[item] + amount
    end

    onInventoryChange(inventory)

    return true;
end

function removeItem(inventory, item, amount)
    if(not (inventory and item and amount)) then
	return false
    end

    if(not inventory.items[item] or inventory.items[item] < amount) then
	return false;
    end

    inventory.items[item] = inventory.items[item] - amount

    if(inventory.items[item] == 0) then
	inventory.items[item] = nil
    end

    onInventoryChange(inventory)

    return true;
end

function moveItem(from, to, item, amount)
    if(not removeItem(from, item, amount)) then
	return false
    end
    if(not addItem(to, item, amount)) then
	addItem(from, item, amount) -- @todo does this always work?
	return false
    end

    onInventoryChange(from)
    onInventoryChange(to)

    return true
end

addEventHandler("onResourceStart", getRootElement(),
    function(res)
	if(getResourceName(res) == "inventory") then
	    for _, player in pairs(getElementsByType('player')) do
		loadPlayerInventory(player)
	    end
	    for _, vehicle in pairs(getElementsByType('vehicle')) do
		loadVehicleInventory(vehicle)
	    end
	end
    end
)

addEventHandler("onPlayerJoin", getRootElement(),
    function()
	loadPlayerInventory(source)
    end
) -- @todo should be onPlayerLogin


addEventHandler("onVehicleSpawn", getRootElement(),
    function()
	loadVehicleInventory(source)
    end
)

addEventHandler("onVehicleEnter", getRootElement(),
    function(player, seat)
	triggerClientEvent(player, "onClientVehicleInventoryChange", player, inventories[source])
    end
)

addEventHandler("onVehicleExit", getRootElement(),
    function(player, seat)
	triggerClientEvent(player, "onClientVehicleInventoryChange", player, nil)
    end
)

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
addCommandHandler("take", take)

function give(player, command, item, amount)
    if(not (item and amount)) then
	outputChatBox("Wrong syntax, use /give <item> <amount>", player)
    end

    local vehicleInventory = inventories[getPedOccupiedVehicle(player)]

    if(not moveItem(inventories[player], vehicleInventory, getItemFromName(item), tonumber(amount))) then
	outputChatBox("failed", player)
    end

end
addCommandHandler("give", give)
