elidragon.hud_info = {
	{0x3BDE1C, "ELIDRAGON Skyblock"},
	{0x334FFF, "Discord: discord.gg/F5ABpPE"},
	{0xF1E81C, "IRC: #elidragon-skyblocks (irc.edgy1.net)"},
	{0xF500AC, "Donations <3: elidragon.com/donate"},
	{0xE20019, "You can use /hub /shop and /island"},
}

minetest.register_on_newplayer(function(player)
	minetest.after(0.1, function()
		minetest.chat_send_all(minetest.colorize("#00D600", player:get_player_name() .. " has joined the Server for the first Time! Welcome!"))
	end)
end)

minetest.register_on_joinplayer(function(player)
	for i, elem in pairs(elidragon.hud_info) do
		player:hud_add({
			hud_elem_type = "text",
			position = {x = 1, y = 0},
			offset = {x = -300, y = i * 18 + 5},
			text = elem[2],
			alignment = {x = 1, y = -1},
			scale = {x = 100, y = 100},
			number = elem[1]
		})
	end
end)

minetest.register_tool("elidragon:stick", {
    description = "God Stick",
    inventory_image = "default_stick.png",
    tool_capabilities = {
        max_drop_level=100,
        groupcaps= {
            cracky={times={[1]=0, [2]=0, [3]=0}, maxlevel=100},
            choppy={times={[1]=0, [2]=0, [3]=0}, maxlevel=100},
            crumbly={times={[1]=0, [2]=0, [3]=0}, maxlevel=100},
            snappy={times={[1]=0, [2]=0, [3]=0}, maxlevel=100},
            not_in_creative_inventory={times={[1]=0, [2]=0, [3]=0}, maxlevel=100},
        }
    }
})

minetest.register_alias("elidragon_server:god_stick", "elidragon:stick")

minetest.register_alias_force("default:sign_yard", "default:sign_wood_yard")
