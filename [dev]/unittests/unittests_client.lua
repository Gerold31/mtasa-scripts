addEvent("clientUnitTestFunctionCall", true)
addEventHandler("clientUnitTestFunctionCall", root, function (funcname, ...)
	local args = {...}
	local returnData = nil
	local suc, msg = pcall(function ()
		local func = loadstring("return "..funcname)()
		returnData = {func(unpack(args))}
	end)
	if (suc) then
		triggerServerEvent("serverUnitTestFunctionCallReturn", root, suc, msg, unpack(returnData))
	else
		triggerServerEvent("serverUnitTestFunctionCallReturn", root, suc, msg)
	end
end, false)
