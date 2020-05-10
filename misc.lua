minetest.register_on_newplayer(function(player)
	minetest.after(0.1, function()
		minetest.chat_send_all(minetest.colorize("#00D600", player:get_player_name() .. " has joined the Server for the first Time! Welcome!"))
	end)
end)

minetest.register_on_joinplayer(function(player)
    minetest.chat_send_player(player:get_player_name(), 
        minetest.colorize("#D6CD00", " ELIDRAGON") .. "\n" ..
        minetest.colorize("#6076FF"," Join our discord Server (discord.gg/Z7SfXYx) or our IRC channel (#elidragon-skyblocks on irc.edgy1.net)") .. "\n" ..
        minetest.colorize("#E27900", " Go to hub using /hub") .. "\n" ..
        minetest.colorize("#00F0FF", " Use /island to teleport to your island") .. "\n" ..
        minetest.colorize("#83FF00", " NEWS: ") .. minetest.colorize("#FFFFFF", elidragon.savedata.news or "No current News")
	)
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
