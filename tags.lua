if not elidragon.savedata.areas then
	elidragon.savedata.areas = {}
end
function elidragon.get_area_with_tag(name, tag)
	local player = minetest.get_player_by_name(name)
	for _, player_area in pairs(areas:getAreasAtPos(player:get_pos())) do
		for _, marked_area in pairs(elidragon.savedata.areas) do
			if player_area.name == marked_area.name and marked_area.tag == tag and minetest.check_player_privs(player_area.owner, {server = true}) then
				return marked_area
			end
		end
	end
end
minetest.register_chatcommand("add_tag", {
	description = "Add tag to area",
	param = "<area> <tag> <param>",
	privs = {server = true},
	func = function(name, param)
		if not param then
			minetest.chat_send_player(name, "Invalid Usage")
			return
		end
		local area = {
			name = param:split(" ")[1],
			tag = param:split(" ")[2],
			param = param:split(" ")[3],
		}
		if not area.name or not area.tag then
			minetest.chat_send_player(name, "Invalid Usage")
			return
		end
		if not area.param then
			area.param = ""
		end
		elidragon.savedata.areas[#elidragon.savedata.areas + 1] = area
		minetest.chat_send_player(name, "tag added. ")
	end
})
minetest.register_chatcommand("remove_tag", {
	description = "Remove tag from area",
	param = "<area> <tag>",
	privs = {server = true},
	func = function(name, param)
		param = param or ""
		for i, area in pairs(elidragon.savedata.areas) do
			if area.name == param:split(" ")[1] and (area.tag == param:split(" ")[2] or not param:split(" ")[2]) then
				table.remove(elidragon.savedata.areas, i)
				minetest.chat_send_player(name, "Tag removed.")
			end
		end
	end
})
minetest.register_chatcommand("print_tags", {
	description = "Print area tags",
	param = "[<area>]",
	privs = {server = true},
	func = function(name, param)
		for _, area in pairs(elidragon.savedata.areas) do
			if param == "" or param == area.name then
				minetest.chat_send_player(name, area.name .. " | " .. area.tag .. " | " .. area.param)
			end
		end
	end
})
function elidragon.limit_tick()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local rank = elidragon.get_rank(player).name
		local privs = minetest.get_player_privs(name)
		local has_fly = rank ~= "player"
		if rank ~= "admin" then
			privs.tp_tpc = nil
		end
		local teleport_area = elidragon.get_area_with_tag(name, "teleport")
		if teleport_area then
			elidragon.teleport(name, teleport_area.param)
		end
		if elidragon.get_area_with_tag(name, "movement") and rank ~= "admin" and rank ~= "moderator" and rank ~= "dev" and rank ~= "helper" then
			privs.fly = nil
			privs.fast = nil
			privs.home = nil
			privs.tp = nil

			if rawget(_G, "armor") then
				local inv = player:get_inventory()
				local _, armor_inv = armor:get_valid_player(player, "[elidragon.limit_tick]")
				for i, stack in pairs(armor_inv:get_list("armor")) do
					if stack:get_name() == "lavastuff:boots" then
						local left = inv:add_item("main", stack)
						inv:set_stack("armor", i, left)
						armor_inv:set_stack("armor", i, left)
						armor:set_player_armor(player)

						local is_emtpy = left:is_empty()
						minetest.chat_send_player(name, minetest.colorize("#FF002C", is_emtpy
							and "Uneqipping your lava boots automatically"
							or "Please take off your lava boots in this zone!"
						))

						if not is_emtpy then
							elidragon.skyblock.spawn_player(player)
						end

						break
					end
				end
			end
		else
			privs.home = true
			privs.tp = true
			if has_fly then
				privs.fly = true
				privs.fast = true
			end
		end
		local kill_area = elidragon.get_area_with_tag(name, "kill")
		if kill_area then
			player:set_pos({x = 0, y = -1000, z = 0})
			player:set_hp(0)
			if kill_area.param ~= "" then
				elidragon.message(kill_area.param:gsub("%%", " "):gsub("@player", name))
			end
		end
		minetest.set_player_privs(name, privs)
	end
	minetest.after(0.5, elidragon.limit_tick)
end
minetest.after(0, elidragon.limit_tick)
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if elidragon.get_area_with_tag(player:get_player_name(), "no_pvp") then
		minetest.chat_send_player(hitter:get_player_name(), minetest.colorize("#FF6737", "You can not PVP here!"))
		return true
	end
end)
minetest.register_on_player_hpchange(function(player, hp_change)
	local name = player:get_player_name()
	if elidragon.get_area_with_tag(name, "no_damage") and hp_change < 0 then
		return 0
	end
	return hp_change
end, true)
minetest.register_on_player_hpchange(function(player, hp_change)
	local name = player:get_player_name()
	local teleport_area = elidragon.get_area_with_tag(name, "teleport_on_damage")
	if teleport_area and hp_change < 0 then
		elidragon.teleport(name, teleport_area.param)
		return 0
	end
	return hp_change
end, true)
