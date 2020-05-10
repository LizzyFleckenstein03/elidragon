minetest.register_chatcommand("setnews", {
	params = "<news>",
	description = "Set news",
	privs = {server = true},
	func = function(player, param)
		elidragon.savedata.news = param
	end,
})
minetest.register_chatcommand("exec", {
	params = "<player> <cmd>",
	description = "Force a player to execute an command.",
	privs = {server = true},
	func = function(player, param)
		minetest.chat_send_player(player, "/exec is deprecated. Use /sudo instead")
		if param:split(' ') and minetest.chatcommands[param:split(' ')[2]] then
			minetest.chatcommands[param:split(' ')[2]].func(param:split(' ')[1])
		end
	end,
})
minetest.register_chatcommand("execparam", {
	params = "<player>-<cmd>-<param>",
	description = "Force a player to execute an command with parameters.",
	privs = {server = true},
	func = function(player, param)
		minetest.chat_send_player(player, "/execparam is deprecated. Use /sudo instead")
		minetest.chatcommands[param:split('-')[2]].func(param:split('-')[1],param:split('-')[3])
	end,
})
minetest.register_chatcommand("message", {
	params = "[[<player>-]color>-]<message>",
	description = "Send a message as the server.",
	privs = {server = true},
	func = function(player, param)
        elidragon.message(param)
	end,
})
minetest.register_chatcommand("colormsg", {
	params = "[[<player>-]color>-]<message>",
	description = "Send a message as the server. [deprecated, replaced my the message command]",
	privs = {server = true},
	func = function(name, param)
        elidragon.message(param)
        minetest.chat_send_player(name, "/colormsg is deprecated. Use /message instead")
	end,
})
minetest.register_chatcommand("colormsgone", {
	params = "[[<player>-]color>-]<message>",
	description = "Send a message as the server. [deprecated, replaced my the message command]",
	privs = {server = true},
	func = function(name, param)
        elidragon.message(param)
         minetest.chat_send_player(name, "/colormsgone is deprecated. Use /message instead")
	end,
})

minetest.register_chatcommand("wielded", {
	params = "",
	description = "Print Itemstring of wielded Item",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
        if player then
            local item = player:get_wielded_item()
            if item then 
                minetest.chat_send_player(name, item:get_name())
            end
        end
	end,
})

minetest.register_chatcommand("sudo", {
	description = "Force other players to run commands",
	params = "<player> <command> <arguments...>",
	privs = {server = true},
	func = function(name, param)
		local target = param:split(" ")[1]
		local command = param:split(" ")[2]
		local arguments
		local argumentsdisp
		local cmddef = minetest.chatcommands
		_, _, arguments = string.match(param, "([^ ]+) ([^ ]+) (.+)")
		if not arguments then arguments = "" end
		if target and command then
			if cmddef[command] then
				if minetest.get_player_by_name(target) then
					if arguments == "" then argumentsdisp = arguments else argumentsdisp = " " .. arguments end
					cmddef[command].func(target, arguments)
				else
					minetest.chat_send_player(name, minetest.colorize("#FF0000", "Invalid Player."))
				end
			else
				minetest.chat_send_player(name, minetest.colorize("#FF0000", "Nonexistant Command."))
			end
		else
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "Invalid Usage."))
		end
	end
})
