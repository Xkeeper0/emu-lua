function handler()
	print "*** SCRIPT ERROR ***"
	print(debug.traceback())
end

print "Welcome to ShitHawk! 1"

xpcall(function () require("shims/script") end, handler)
