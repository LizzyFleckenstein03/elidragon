function playerlist.iterator()
	local list = {}
	for _, player in ipairs(minetest.get_connected_players()) do
		local rank, i = elidragon.get_rank(player)
		table.insert(list, {
			player = player,
			value = i,
			color = tonumber(rank.color:gsub("#", ""), 16)
		})
	end
	table.sort(list, function(a, b)
		return a.value > b.value
	end)
	local i = 0
	return function()
		i = i + 1
		local elem = list[i]
		if elem then
			return i, elem.player, elem.color
		end
	end
end
