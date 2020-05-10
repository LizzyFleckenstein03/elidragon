elidragon.ranks = {
	{
        name = "player",
        privs = {interact = true, shout = true, home = true, tp = true},
        color = "#FFFFFF",
        tag = "",
    },
    {
		name = "vip",
		privs = {fly = true, fast = true},
		color = "#16AE00",
		tag = "[VIP]",
	},
	{
		name = "builder",
		privs = {creative = true, worldedit = true, areas = true},
		color = "#EE6E00",
		tag = "[BUILDER]",
	},
	{
		name = "helper",
		privs = {kick = true, noclip = true, settime = true, give = true, teleport = true},
		color = "#EBEE00",
		tag = "[HELPER]",
	},
	{
		name = "moderator",
		privs = {ban = true, bring = true, invhack = true, vanish = true, protection_bypass = true},
		color = "#001FFF",
		tag = "[MODERATOR]",
	},
	{
		name = "admin",
		privs = {server = true, privs = true},
		color = "#FF2D8D",
		tag = "[ADMIN]",
	},
}

if not elidragon.savedata.ranks then
	local file = io.open(minetest.get_worldpath() .. "/ranks.json", "r")
	local jsondata = file:read()
	elidragon.savedata.ranks = minetest.parse_json(jsondata)
end

function elidragon.get_rank(name)
    return elidragon.get_rank_by_name(elidragon.savedata.ranks[name] or "player")
end

function elidragon.get_rank_by_name(rankname)
	for _, rank in pairs(elidragon.ranks) do
		if rank.name == rankname then
			return rank
		end
	end
end

function elidragon.get_player_name(name, color, brackets)
    local rank = elidragon.get_rank(name)
    local rank_tag = rank.tag
    if color then 
		rank_tag = minetest.colorize(rank.color, rank_tag)
	end
	if not brackets then 
		brackets = {"",""}
	end
	return rank_tag .. brackets[1] .. name .. brackets[2] .. " "
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
    minetest.chat_send_all(elidragon.get_player_name(name, true) .. "has joined the Server.")
    if irc.connected and irc.config.send_join_part then
        irc.say(elidragon.get_player_name(name) .. "has joined the Server.")
    end
    player:set_nametag_attributes({color = elidragon.get_rank(name).color})
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
    minetest.chat_send_all(elidragon.get_player_name(name, true) .. "has left the Server.")
    if irc.connected and irc.config.send_join_part then
        irc.say(elidragon.get_player_name(name) .. "has left the Server.")
    end
end)

minetest.register_on_chat_message(function(name, message)
    minetest.chat_send_all(elidragon.get_player_name(name, true, {"<", ">"}) .. message)
    if irc.connected and irc.joined_players[name] then
        irc.say(elidragon.get_player_name(name, false, {"<", ">"}) .. message)
    end
    return true
end)

minetest.register_chatcommand("rank", {
	params = "<player> <rank>",
	description = "Set a player's rank (admin|moderator|helper|builder|vip|player)",
	privs = {privs = true},
	func = function(name, param)
		local target = param:split(' ')[1]
		local player = minetest.get_player_by_name(name)
		local rank = param:split(' ')[2]
		if not elidragon.get_rank_by_name(rank) then 
            minetest.chat_send_player(name, "Invalid Rank: " .. rank)
        else
			local privs = {}
			for _, r in pairs(elidragon.ranks) do
				for k, v in pairs(r.privs) do
					privs[k] = v
				end
				if r.name == rank then
					break
				end
			end
			minetest.set_player_privs(target, privs)
			if player then
				player:set_nametag_attributes({color = rank.color})
			end
			minetest.chat_send_all(target .. " is now a " .. minetest.colorize(rank.color, rank.name))
		end
	end,
})
