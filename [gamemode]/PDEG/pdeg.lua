local posX, posY, posZ = 2485, -1667, 13.3

function spawn(player)
	if not isElement(player) then return end

	spawnPlayer(player, posX, posY, posZ)
	fadeCamera(player, true)
	setCameraTarget(player, player)
	showChat(player, true)
end

addEventHandler("onPlayerJoin", getRootElement(),
	function()
		spawn(source)
	end
)

addEventHandler("onPlayerWasted", getRootElement(),
	function()
		setTimer(spawn, 1800, 1, source)
	end
)
