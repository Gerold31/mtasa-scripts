addEventHandler("onClientVehicleDamage", getRootElement(),
	function (attacker, weapon, loss, x, y, z, type)
		outputChatBox("loss: " .. tonumber(loss))
		if (weapon == nil and loss > 0 and loss < 1000) then
			local health = source:getHealth()
			local maxloss = 0.0002 * loss * loss * loss
			local diff = maxloss - (1000 - health)
			local new_loss = 0.3 * diff
			local vtype = source:getVehicleType()

			outputChatBox("type: " .. vtype)
			if (vtype ~= "Automobile" and vtype ~= "Monster Truck" and vtype ~= "Trailer") then
				return
			end

			if (new_loss > 0) then
				local new_helth = health - new_loss
				if (new_helth < 251) then
					new_helth = 251
					source:setEngineState(false)
				end
				source:setHealth(new_helth + loss)
				outputChatBox("damage: " .. tonumber(health) .. " -> " .. tonumber(new_helth))
			else
				source:setHealth(health + loss)
			end
		end
	end
)
