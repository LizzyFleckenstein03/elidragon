elidragon.warps = {
	shop = {
		desc = "Shop",
		pos = {x = 0, y = 1000.5, z = 0}
	},
	hub = {
		desc = "Hub",
		pos = {x = 10071, y = 10003, z = 9951},
	},
	pvp = {
		desc = "PvP Area",
		pos = {x = 20025, y = 1003, z = 1025},
	},
	spawn = {
		desc = "Spawn",
		pos = {x = -21, y = 10202.5, z = -5},
		restricted = true
	},
	jump = {
		desc = "Jumping area",
		pos = {x = 12286, y = 12347, z = 12556},
	},
}

for warp_name, warp in pairs(elidragon.warps) do
	local desc = "Warp to " .. warp.desc

	if warp.restricted then
		desc = desc .. " [only for staff members]"
	end

	minetest.register_chatcommand(warp_name, {
		description = desc,
		privs = {teleport = warp.restricted},
		func = function(name)
			local player = minetest.get_player_by_name(name)

			if player then
				player:set_pos(warp.pos)
			end
		end
	})
end
