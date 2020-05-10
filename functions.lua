function elidragon.teleport(name, pos_str)
	local player = minetest.get_player_by_name(name)
	local pos = {}
	if pos_str then
		local pos_arr = pos_str:split(",")
		pos.x = tonumber(pos_arr[1])
		pos.y = tonumber(pos_arr[2])
		pos.z = tonumber(pos_arr[3])
	end
	if player and pos.x and pos.y and pos.z then
		player:set_pos(pos)
	end
end
function elidragon.message(message)
    if not message then 
        return 
    end
    local name = message:split('-')[1] 
	local color = message:split('-')[2]
	local msg = message:split('-')[3]
    if not msg then
        msg = color
        color = name
        name = nil
    end
    if not msg then 
        msg = color
        color = "#FFFFFF"
    end
    if not msg then
        return
    end
    print(name, color, msg)
    msg = minetest.colorize(color, msg)
    if name then
        minetest.chat_send_player(name, msg)
    else
        minetest.chat_send_all(msg)
    end
end
function elidragon.load()
	local file = io.open(minetest.get_worldpath() .. "/elidragon", "r")
	if file then
		elidragon.savedata = minetest.deserialize(file:read())
		file:close()
	else
		elidragon.savedata = {}
	end
end
function elidragon.save()
	local file = io.open(minetest.get_worldpath() .. "/elidragon", "w")
	file:write(minetest.serialize(elidragon.savedata))
	file:close()
end
elidragon.load()
minetest.register_on_shutdown(elidragon.save)
