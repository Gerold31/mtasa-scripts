tester = nil

local unitTests = {}

local cResourceName = nil
local cTestIds = nil
local routine = nil

local success = true
local cTestId = nil
local cTestName = nil
local cDataName = nil

-- local functions
local runUnitTests = nil
local resumeUnitTests = nil
local startUnitTests = nil

runUnitTests = function (resourceName, testIds, jumpAfter)
	if (testIds == nil) then
		testIds = {}
		for id, _ in pairs(unitTests[resourceName]) do
			table.insert(testIds, id)
		end
	elseif (type(testIds) ~= "table") then
		testIds = {testIds}
	end

	if (not jumpAfter) then
		println("Start tests for '" .. resourceName .. "' ...")
	end
	local isBehindTest = false
	local isTestNamePrinted = false
	for _, testId in ipairs(testIds) do
		if (not jumpAfter or testId == jumpAfter.testId) then
			local test = unitTests[resourceName][testId]
			cTestId = testId
			cTestName = test.name
			local isBehindData = false
			for _, testDataSet in pairs(test.data) do
				local dataName = testDataSet.name
				local testData = testDataSet.data
				if (not jumpAfter or isBehindTest or isBehindData) then
					if (not isTestNamePrinted and (not jumpAfter or testId ~= jumpAfter.testId)) then
						println("  Run test '" .. test.name .. "' (" .. testId .. ") ...")
						isTestNamePrinted = true
					end
					success = true
					cDataName = dataName
					--local suc, msg = pcall(function ()
					--	test.func(testData)
					--end)
					--if (not suc) then
					--	errormessage(msg)
					--end
					test.func(testData)
				end
				if (not jumpAfter or dataName == jumpAfter.dataName) then
					isBehindData = true
				end
			end
		end
		isBehindTest = true
	end
end

resumeUnitTests = function ()
	local suc, msg = coroutine.resume(routine)
	if (not suc) then
		errormessage(msg)
		startUnitTests(cResourceName, cTestIds, {testId = cTestId, dataName = cDataName})
	elseif (coroutine.status(routine) == "dead") then
		println("All tests compleate.")
		if (tester) then
			outputChatBox("All tests compleate.", tester, 0, 255, 0)
		end
		routine = nil
	end
end

startUnitTests = function (resourceName, testIds, jumpAfter)
	cResourceName = resourceName
	cTestIds = testIds
	routine = coroutine.create(function ()
		runUnitTests(resourceName, testIds, jumpAfter)
	end)
	resumeUnitTests()
end

addCommandHandler("unittest", function (player, command, ...)
	if (not player) then
		outputServerLog("You must be a player to run this command.")
		return
	end

	local args = {...}
	if (#args == 1 and args[1] == "status") then
		if (routine == nil) then
			outputChatBox("There is no active test.", player)
		else
			outputChatBox("There is an active test:", player)
			outputChatBox("  status:  " .. coroutine.status(routine), player)
			outputChatBox("  current data:  " .. cDataName, player)
		end
		return
	end

	if (routine) then
		outputChatBox("Another unittest is still running.", player, 255, 0, 0)
		return
	end

	local args = {...}
	tester = player

	if (#args == 0) then
		outputChatBox("Usage: /" .. command .. " <resource> [test]", player, 255, 255, 0)
		outputChatBox("   or: /" .. command .. " list [resource]", player, 255, 255, 0)
	elseif (#args == 1 and args[1] == "list") then
		for key, _ in pairs(unitTests) do
			outputChatBox("    " .. key, player)
		end
	elseif (#args == 2 and args[1] == "list") then
		if (not getResourceFromName(args[2])) then
			outputChatBox("Resource not found.", player, 255, 0, 0)
			return
		end
		local tests = unitTests[args[2]]
		if (tests == nil) then
			outputChatBox("No tests found.", player, 255, 0, 0)
			return
		end
		for key, _ in pairs(tests) do
			outputChatBox("    " .. key, player)
		end
	elseif (#args == 1) then
		if (not getResourceFromName(args[1])) then
			outputChatBox("Resource not found.", player, 255, 0, 0)
			return
		end
		if (unitTests[args[1]] == nil) then
			outputChatBox("No tests found.", player, 255, 0, 0)
			return
		end
		startUnitTests(args[1])
		if (routine) then
			outputChatBox("Test started...", player, 0, 255, 0)
		end
	elseif (#args == 2) then
		if (not getResourceFromName(args[1])) then
			outputChatBox("Resource not found.", player, 255, 0, 0)
			return
		end
		local tests = unitTests[args[1]]
		if (tests == nil) then
			outputChatBox("No tests found for this resource.", player, 255, 0, 0)
			return
		end
		if (not tests[args[2]]) then
			outputChatBox("Test not found.", player, 255, 0, 0)
			return
		end
		startUnitTests(args[1], args[2])
		if (routine) then
			outputChatBox("Test started...", player, 0, 255, 0)
		end
	else
		outputChatBox("Invalid amount of arguments.", player, 255, 0, 0)
	end
end, true)


function println(line)
	outputServerLog(line)
	outputConsole(line, tester)
end

function errormessage(msg)
	if (success) then
		println("!   Error while running test: " .. tostring(cDataName))
		success = false
	end
	println("!     " .. msg)
end

function addUnitTest(resourceName, testId, testName, testFunc)
	if (unitTests[resourceName] == nil) then
		unitTests[resourceName] = {}
	end
	unitTests[resourceName][testId] = {
		name = testName,
		func = testFunc,
		data = {}
	}
end

function addTestData(resourceName, testId, dataName, data)
	local test = assert(assert(unitTests[resourceName], "invalid resource name")[testId], "invalid test name")
	table.insert(test.data, {name = dataName, data = data})
end

function callClientFunction(funcname, ...)
	triggerClientEvent(tester, "clientUnitTestFunctionCall", root, funcname, ...)

	local returnValues = nil
	local clientSuccess = nil
	local clientMsg = nil
	local onReturnFunc = nil
	onReturnFunc = function (suc, msg, ...)
		removeEventHandler("serverUnitTestFunctionCallReturn", root, onReturnFunc)
		returnValues = {...}
		clientSuccess = suc
		clientMsg = msg
		resumeUnitTests()
	end
	addEventHandler("serverUnitTestFunctionCallReturn", root, onReturnFunc, false)
	coroutine.yield()

	if (not clientSuccess) then
		error(clientMsg)
	end
	return unpack(returnValues)
end

addEvent("serverUnitTestFunctionCallReturn", true)
