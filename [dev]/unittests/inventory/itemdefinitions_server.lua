local RESOURCE_NAME = "inventory"
local TEST_ID = "definitions"

addUnitTest(RESOURCE_NAME, TEST_ID, "Item-Definitions: Basics", function (data)
	data.volume = tostring(data.volume)
	data.mass = tostring(data.mass)
	test_itemdefinition(data)
	callClientFunction("test_itemdefinition", data)
end)

addTestData(RESOURCE_NAME, TEST_ID, "Item-Id 1", {
	id = 1,
	name = "Stone",
	localisations = {de = "Stein"}, -- TODO test it
	volume = 1,
	mass = 1,
	divisible = true,
	dataTypes = nil, -- TODO test it
	defaultData = nil, -- TODO test it
	isWeapon = false,
	weaponId = nil,
	weaponType = nil
})

addTestData(RESOURCE_NAME, TEST_ID, "Item-Id 105", {
	id = 105,
	name = "Baseball Bat",
	localisations = {de = "Baseballschläger"},
	volume = 1.4,
	mass = 0.85,
	divisible = false,
	dataTypes = nil,
	defaultData = nil,
	isWeapon = true,
	weaponId = 5,
	weaponType = "melee"
})

addTestData(RESOURCE_NAME, TEST_ID, "Item-Id 124", {
	id = 124,
	name = "Desert Eagle",
	localisations = {},
	volume = 0.2,
	mass = 0.8,
	divisible = false,
	dataTypes = nil,
	defaultData = nil,
	isWeapon = true,
	weaponId = 24,
	weaponType = "default"
})

addTestData(RESOURCE_NAME, TEST_ID, "Item-Id 142", {
	id = 142,
	name = "Fire Extinguisher",
	localisations = {de = "Feuerlöscher"},
	volume = 5.6,
	mass = 3.8,
	divisible = false,
	dataTypes = {ammo = "number"},
	defaultData = {ammo = 500},
	isWeapon = true,
	weaponId = 42,
	weaponType = "noreload"
})
