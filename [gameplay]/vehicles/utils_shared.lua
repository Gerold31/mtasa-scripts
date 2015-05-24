function invalid_call(msg, level)
	level = level or 0
	local info1 = debug.getinfo(level + 2, "n")
	local info2 = debug.getinfo(level + 3, "nl")
	local sname = info2 and info2.name or "?"
	local sline = info2 and info2.currentline or "?"
	local tname = info1 and info1.name or "?"
	outputDebugString("[" .. sname .. "(" .. sline .. ")] Invalid call of " .. tname .. ": " .. msg, 2)
end
