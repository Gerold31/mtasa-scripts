addEventHandler( "onResourceStart", resourceRoot,
	function ()
		local stone = getItemDefinition("stone")
		outputDebugString("Server - tostring: " .. tostring(stone), 3)
		debugItemDefinition("stone", "Server - ")
		debugItemDefinition("mp5", "Server - ")
	end
)
addEventHandler( "onClientResourceStart", resourceRoot,
	function ()
		debugItemDefinition("stone", "Client - ")
		debugItemDefinition("mp5", "Client - ")
	end
)

function debugItemDefinition(id, prefix)
	prefix = prefix or ""
	local definition = getItemDefinition(id)
	outputDebugString(prefix .. "       id: " .. tostring(definition:getId()), 3)
	outputDebugString(prefix .. "     name: " .. tostring(definition:getName()), 3)
	outputDebugString(prefix .. "localized: " .. tostring(definition:getLocalizedName("de")), 3)
	outputDebugString(prefix .. "   weight: " .. tostring(definition:getWeight()), 3)
	outputDebugString(prefix .. "   volume: " .. tostring(definition:getVolume()), 3)
	outputDebugString(prefix .. "divisible: " .. tostring(definition:isDivisible()), 3)
end
