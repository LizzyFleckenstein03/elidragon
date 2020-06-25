local C = minetest.get_color_escape_sequence

function elidragon.get_emtpy_highscore_list()
	local list = {}
	for i = 1, 10 do
		list[i] = {name = "<empty>", score = 0}
	end
	return list
end

elidragon.savedata.xp_highscore = elidragon.savedata.xp_highscore or elidragon.get_emtpy_highscore_list()

function elidragon.check_for_highscore(player)
	local list = elidragon.savedata.xp_highscore
	local name = player:get_player_name()
	local score = elidragon.get_xp(player)
	local old_rank, new_rank
	for i, e in pairs(list) do
		if e.name == name then
			old_rank = i
		end
		if not new_rank and score >= e.score then
			new_rank = i
		end
	end
	if not new_rank then
		return
	elseif new_rank == old_rank then
		list[old_rank].score = score
		return
	elseif old_rank then
		table.remove(list, old_rank)
	else
		table.remove(list, 10)
	end
	table.insert(list, new_rank, {name = name, score = score})
	minetest.chat_send_all(C("#ACF317") .. name .. C("#0064E4") .. " is now rank " .. C("#E4E400") .. new_rank .. C("#0064E4") .. " on the PvP highscore list with " .. C("#E4E400") .. score .. C("#0064E4") .. " XP.")
end

function elidragon.add_xp(player, amount)
	local xp = elidragon.get_xp(player)
	player:get_meta():set_int("elidragon:xp", xp + amount)
	elidragon.check_for_highscore(player)
end

function elidragon.get_xp(player)
	return player:get_meta():get_int("elidragon:xp")
end 

minetest.register_on_dieplayer(function(player, reason)
	local object = reason.object
	if not object then return end
	local killer
	if object:is_player() then
		killer = object
	else
		local object_name = object:get_luaentity().name
		if object_name == "bow:arrow" then
			local owner =  minetest.get_player_by_name(object:get_luaentity().owner or "")
			if owner and owner:is_player() then
				killer = owner
			end
		end
	end
	if killer and elidragon.get_area_with_tag(killer:get_player_name(), "pvp") then
		minetest.chat_send_all(minetest.colorize("#D3FF2A", killer:get_player_name() .. " has killed " .. player:get_player_name() .. " in the PvP area!"))
		local earned_xp = math.floor(5 + math.sqrt(elidragon.get_xp(player)))
		elidragon.add_xp(killer, earned_xp)
		minetest.chat_send_player(killer:get_player_name(), C("#00F5FF") .. "You earned " .. C("#C000AC") .. earned_xp .. C("#00F5FF") .. " XP. Use /xp to view your total score." .. C("#FFFFFF")) 
	end
end)

minetest.register_on_joinplayer(elidragon.check_for_highscore)

minetest.register_chatcommand("xp", {
	desc = "View your's or another player's PvP XP",
	param = "[<player>]",
	func = function(name, param)
		local target = name
		if param and param ~= "" then
			target = param
		end
		local target_ref = minetest.get_player_by_name(target)
		if not target_ref then return false, "Player '" .. target .. "' is not online." end
		return true, C("#C00D00") .. "Score of " .. target .. ": " .. C("#9AB3FF") .. elidragon.get_xp(target_ref) .. " XP" .. C("#FFFFFF")
	end
})

minetest.register_chatcommand("rankings", {
	description = "View the PvP highscore list",
	func = function(name)
		local msg = C("#07E400") .. "PvP Highscore List:"
		for i, e in pairs(elidragon.savedata.xp_highscore) do
			msg = msg .. "\n" .. C("#F4F73C") .. i .. ". " .. C("#3CF7EF") .. e.name .. C("#5DF73C") .. " (" .. e.score .. " XP)"
		end
		return true, msg
	end
})
