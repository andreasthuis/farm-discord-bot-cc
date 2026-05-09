local coms = {}

local modemSide = nil

function coms.init()
	print("Initializing communication module...")
	for _, side in ipairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" then
			modemSide = side
			break
		end
	end

	if not modemSide then
		print("Error: No modem found!")
		return
	end

	rednet.open(modemSide)
	print("Rednet opened on: " .. modemSide)
end

function coms.sendMessage(message)
	rednet.broadcast(message)
end

function coms.listen()
	while true do
		local senderId, message, protocol = rednet.receive()
		print(string.format("Received from %d: %s (Protocol: %s)", senderId, message, protocol))
	end
end

return coms