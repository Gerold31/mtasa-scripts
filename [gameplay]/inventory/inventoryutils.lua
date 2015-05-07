
items = {
    water_bottle={name="WaterBottle", volume=1, mass=1},
    tire={name="Tire", volume=25, mass=10}
}

function getInventoryVolume(inventory)
    if(not inventory) then
	return nil
    end

    local volume = 0
    for item, amount in pairs(inventory.items) do
	volume = volume + amount * items[item].volume
    end
    return volume
end

function getInventoryMass(inventory)
    if(not inventory) then
	return nil
    end

    local mass = 0
    for item, amount in pairs(inventory.items) do
	mass = mass + amount * items[item].mass
    end
    return mass
end

function getItemFromName(name)
    for item, value in pairs(items) do
	if(value.name == name) then
	    return item
	end
    end
    return nil
end
