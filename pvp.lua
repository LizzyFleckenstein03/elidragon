local C = minetest.get_color_escape_sequence

function elidragon.add_xp(player, amount)
	local xp = elidragon.get_xp(player)
	player:get_meta():set_int("elidragon:xp", xp + amount)
end

function elidragon.get_xp(player)
	return player:get_meta():get_int("elidragon:xp")
end 

minetest.register_on_dieplayer(function(player, reason)
	if reason.type == "punch" then
		local killer = reason.object
		if killer and killer:is_player() and elidragon.get_area_with_tag(killer:get_player_name(), "pvp") then
			minetest.chat_send_all(minetest.colorize("#D3FF2A", killer:get_player_name() .. " has killed " .. player:get_player_name() .. " in the PvP area!"))
			local earned_xp = math.floor(5 + math.sqrt(elidragon.get_xp(player)))
			elidragon.add_xp(killer, earned_xp)
			minetest.chat_send_player(killer:get_player_name(), C("#00F5FF") .. "You earned " .. C("#C000AC") .. earned_xp .. C("#00F5FF") .. " XP. Use /xp to view your total score." .. C("#FFFFFF")) 
		end
	end
end) 

minetest.register_chatcommand("xp", {
	desc = "View your's or another player's PvP XP",
	param = "[<player>]",
	func = function(name, param)
		local target = name
		if param ~= "" then
			target = param
		end
		local target_ref = minetest.get_player_by_name(name)
		if not target_ref then return false, "Player '" .. target .. "' is not online." end
		return true, C("#C00D00") .. "Score of " .. target .. ": " .. C("#9AB3FF") .. elidragon.get_xp(target_ref) .. " XP" .. C("#FFFFFF")
	end
})
