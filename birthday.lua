elidragon.savedata.birthday = elidragon.savedata.birthday or {}
function elidragon.flower_rain(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	local pos = player:get_pos()
	minetest.add_particlespawner({
		amount = 50,
		time = 2,
		minpos = vector.add(pos, {x = -1, y = 2, z = -1}),
		maxpos = vector.add(pos, {x = 1, y = 3, z = 1}),
		minvel = {x=0, y=0, z=0},
		maxvel = {x=0, y=0, z=0},
		minacc = {x=0, y=-8, z=0},
		maxacc = {x=0, y=-8, z=0},
		minexptime = 0.7,
		maxexptime = 1,
		minsize = 5,
		maxsize = 10,
		collisiondetection = true,
		vertical = true,
		texture = "flowers_rose.png",
	})
	minetest.after(0.5, function() elidragon.flower_rain(name) end)
end
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if elidragon.savedata.birthday[name] == os.date("%d/%m") then
		minetest.chat_send_all(minetest.colorize("#FF20FF", name .. " has joined the game. Today is their birthday!"))
		elidragon.flower_rain(name)
		player:hud_add({
			hud_elem_type = "text",
			position      = {x = 1, y = 0},
			offset        = {x = -5, y = 5},
			text          = "Happy Birthday!",
			alignment     = {x = -1, y = 1},
			scale         = {x = 100, y = 100},
			number    = 0xFFF40A,
		})
	end
end)
minetest.register_chatcommand("birthday", {
	description = "Set your birthday (e.g. 07/09 if your birthday is the seventh of september)",
	param = "DD/MM",
	func = function(name, param)
		elidragon.savedata.birthday[name] = param
		minetest.chat_send_player(name, "Birthday set to " .. param)
	end
})
