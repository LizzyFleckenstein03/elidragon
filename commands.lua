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
