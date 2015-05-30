local RESOURCE_NAME = "inventory"
local TEST_ID = "definitions"

function test_itemdefinition(data)
	local call = exports[RESOURCE_NAME]
	local itemdef = call:getItemDefinition(data.id)
	assert(call:getItemDefinitionId(itemdef) == data.id)
	assert(call:getItemDefinitionName(itemdef) == data.name)
	assert(call:getItemDefinitionMass(itemdef) == tonumber(data.mass))
	assert(call:getItemDefinitionVolume(itemdef) == tonumber(data.volume))
	assert(call:isItemDefinitionDivisible(itemdef) == data.divisible)
	if (data.isWeapon) then
		local w = assert(call:getItemDefinitionWeaponInfo(itemdef))
		assert(w.id == data.weaponId)
		assert(w.type == data.weaponType)
	else
		assert(call:getItemDefinitionWeaponInfo(itemdef) == nil)
	end
end
