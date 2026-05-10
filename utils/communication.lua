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

function coms.send(message, protocol)
	rednet.broadcast(message, protocol)
end

function coms.listen()
	while true do
		local senderId, message, protocol = rednet.receive()
		os.queueEvent("rednet_message", senderId, message, protocol, os.time())
	end
end

return coms