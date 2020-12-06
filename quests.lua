elidragon.quests = {}

elidragon.quests.list = {
	dig_dirt = {
		job = "Dig Dirt",
		desc = "dig 10 x default:dirt or default:dirt_with_grass",
		count = 10,
		parents = {},
		action = "dig",
		items = {"default:dirt", "default:dirt_with_grass"},
		reward = "default:dirt 20",
	},
	get_wood = {
		job = "Get Wood",
		desc = "dig 5 x default:wood",
		count = 5,
		parents = {},
		action = "dig",
		items = {"default:tree"},
		reward = "default:apple 15",
	},
	build_stonegen = {
		job = "Build a stone generator",
		desc = "place default:lava_source using a bucket",
		count = 1,
		parents = {"dig_dirt"},
		action = "place_liquid",
		items = {"default:lava_source"},
		reward = "flowers:waterlily 3",
	},
	craft_wood_pickaxe = {
		job = "Craft a wooden pickaxe",
		desc = "craft default:pick_wood",
		count = 1,
		parents = {"get_wood"},
		action = "craft",
		items = {"default:pick_wood"},
		reward = "default:sand 5",
	},
	dig_cobble = {
		job = "Dig Stone",
		desc = "dig 10 x default:stone",
		count = 10,
		parents = {"craft_wood_pickaxe", "build_stonegen"},
		action = "dig",
		items = {"default:stone"},
		reward = "default:chest_locked",
		goal = "Stone Age",
	},
	craft_stone_pick = {
		job = "Craft a Stone Pickaxe",
		desc = "craft default:pick_stone",
		count = 1,
		parents = {"dig_cobble"},
		action = "craft",
		items = {"default:pick_stone"},
		reward = "default:iron_lump",
	},
	craft_stone_axe = {
		job = "Craft a Stone Axe",
		desc = "craft default:axe_stone",
		count = 1,
		parents = {"craft_stone_pick"},
		action = "craft",
		items = {"default:axe_stone"},
		reward = "default:iron_lump",
	},
	craft_stone_shovel = {
		job = "Craft a Stone Shovel",
		desc = "craft default:shovel_stone",
		count = 1,
		parents = {"dig_cobble"},
		action = "craft",
		items = {"default:shovel_stone"},
		reward = "default:iron_lump",
	},
	craft_stone_sword = {
		job = "Craft a stone sword",
		desc = "craft default:sword_stone",
		count = 1,
		parents = {"craft_stone_shovel", "craft_stone_axe"},
		action = "craft",
		items = {"default:sword_stone"},
		reward = "default:iron_lump",
		goal = "Full Toolset",
	},
	craft_iron_pickaxe = {
		job = "Make an Iron Pick",
		desc = "craft default:pick_steel",
		count = 1,
		parents = {"craft_stone_pick", "craft_furnace"},
		action = "craft",
		items = {"default:pick_steel"},
		reward = "default:dirt 25",
	},
	craft_dirt = {
		job = "Craft some dirt!",
		desc = "craft 99 x default:dirt",
		count = 99,
		parents = {"craft_stone_sword"},
		action = "craft",
		items = {"default:dirt"},
		reward = "protector:protect 5",
	},
	craft_furnace = {
		job = "Make a furnace",
		desc = "craft default:furnace",
		count = 1,
		parents = {"dig_cobble"},
		action = "craft",
		items = {"default:furnace"},
		reward = "default:coal_lump 5",
	},
}

elidragon.quests.active = {}

-- functions

function elidragon.quests.complete(name, queststr)
	local questname = string.gsub(queststr, "elidragon:", "")
	local questdef = elidragon.quests.list[questname]
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local meta = player:get_meta()
	meta:set_string(queststr, "true")
	if questdef.goal then
		minetest.chat_send_all(minetest.colorize("#84FFE3", name .. " has reached the goal ") .. minetest.colorize("#CF24FF", questdef.goal))
		minetest.sound_play("elidragon_reach_goal")
	else
		minetest.sound_play("elidragon_finish_quest", {to_player = name})
	end
	player:get_inventory():add_item("main", ItemStack(questdef.reward))
	elidragon.quests.update(name)
end

function elidragon.quests.update(name)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	local meta = player:get_meta()
	local active_quests = elidragon.quests.active[name]
	local unlock_delay = 2
	for questname, questdef in pairs(elidragon.quests.list) do	
		local queststr = "elidragon:" .. questname
		if not active_quests[questname] and not minetest.is_yes(meta:get_string(queststr)) then
			local unlock = true
			for _, parent in pairs(questdef.parents) do
				if not minetest.is_yes(meta:get_string("elidragon:" .. parent)) then
					unlock = false
					break
				end
			end
			if unlock then
				active_quests[questname] = true
				minetest.after(unlock_delay, function()
					quests.start_quest(name, queststr)
					minetest.sound_play("elidragon_new_quest", {to_player = name})
				end)
				unlock_delay = unlock_delay + 0.5
			end
		end
	end
end

function elidragon.quests.event(name, action, itemstack)
	if not minetest.get_player_by_name(name) then return end
	local item_name = itemstack:get_name()
	local item_count = itemstack:get_count()
	for questname, questdef in pairs(elidragon.quests.list) do
		if questdef.action == action then
			for _, item in pairs(questdef.items) do
				if item == item_name then
					quests.update_quest(name, "elidragon:" .. questname, item_count)
				end
				break
			end
		end
	end
end

-- register quests

for questname, questdef in pairs(elidragon.quests.list) do
	quests.register_quest("elidragon:" .. questname, {
		title = questdef.job,
		description = questdef.desc,
		max = questdef.count,
		autoaccept = true,
		callback = elidragon.quests.complete
	})
end

-- startup

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	elidragon.quests.active[name] = {}
	elidragon.quests.update(name)
	quests.show_hud(name, true)
end)

-- callbacks

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player then return end
	elidragon.quests.event(player:get_player_name(), "craft", itemstack)
end)

minetest.register_on_dignode(function(pos, oldnode, player)
	if not player then return end
	elidragon.quests.event(player:get_player_name(), "dig", ItemStack(oldnode.name))
end)

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
	if not player then return end
	elidragon.quests.event(player:get_player_name(), "place", ItemStack(newnode.name))
end)

minetest.after(0, function()
	for _, liquid in pairs(bucket.liquids) do
		local bucket_item = minetest.registered_items[liquid.itemname]
		local old_on_place = bucket_item.on_place
		minetest.override_item(liquid.itemname, {
			on_place = function(itemstack, user, pointed_thing)
				local result = old_on_place(itemstack, user, pointed_thing)
				if result and ItemStack(result) and ItemStack(result):get_name() == "bucket:bucket_empty" then
					elidragon.quests.event(user:get_player_name(), "place_liquid", ItemStack(liquid.source))
				end
				return result
			end
		})
	end
end)
