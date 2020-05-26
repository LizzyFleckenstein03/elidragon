elidragon.skyblock = {} 

--helper functions

-- http://rosettacode.org/wiki/Spiral_matrix#Lua
av, sn = math.abs, function(s) return s~=0 and s/av(s) or 0 end
local function sindex(y, x)
	if y == -x and y >= x then return (2*y+1)^2 end
	local l = math.max(av(y), av(x))
	return (2*l-1)^2+4*l+2*l*sn(x+y)+sn(y^2-x^2)*(l-(av(y)==l and sn(y)*x or sn(x)*y))
end
local function spiralt(side)
	local ret, id, start, stop = {}, 0, math.floor((-side+1)/2), math.floor((side-1)/2)
	for i = 1, side do
		for j = 1, side do
			local id = side^2 - sindex(stop - i + 1,start + j - 1)
			ret[id] = {x=i,z=j}
		end
	end
	return ret
end

local function ripairs(t)
	local function ripairs_it(t,i)
		i=i-1
		local v=t[i]
		if v==nil then return v end
		return i,v
	end
	return ripairs_it, t, #t+1
end

-- start positions

function elidragon.skyblock.load_legacy_start_positions()
	local file = io.open(minetest.get_worldpath() .. "/skyblock.start_positions", "r")
	if file then
		local start_positions = {}
		while true do
			local x = file:read("*n")
			if x == nil then
				break
			end
			local y = file:read("*n")
			local z = file:read("*n")
			table.insert(start_positions, {x = x, y = y, z = z})
		end
		file:close()
		return start_positions
	end
end

function elidragon.skyblock.load_start_positions()
	local file = io.open(minetest.get_worldpath() .. "/start_positions", "r")
	if file then
		local start_positions = minetest.deserialize(file:read())
		file:close()
		return start_positions
	end
end

function elidragon.skyblock.save_start_positions(start_positions)
	local file = io.open(minetest.get_worldpath() .. "/start_positions", "w")
	file:write(minetest.serialize(start_positions))
	file:close()
end

function elidragon.skyblock.generate_start_positions()
	local start_positions = {}
	for _, v in ripairs(spiralt(1000)) do
		local pos = {x = v.x * 32, y = math.random(4 - 8, 4 + 8), z = v.z * 32}
		table.insert(start_positions, pos)
	end
	return start_positions
end

elidragon.skyblock.start_positions = elidragon.skyblock.load_start_positions() 

if not elidragon.skyblock.start_positions then
	elidragon.skyblock.start_positions = elidragon.skyblock.load_legacy_start_positions() or elidragon.skyblock.generate_start_positions()
	elidragon.skyblock.save_start_positions(elidragon.skyblock.start_positions)
end

function elidragon.skyblock.load_legacy_last_start_id()
	local file = io.open(minetest.get_worldpath() .. "/skyblock.last_start_id", "r")
	if file then
		local last_start_id = tonumber(file:read())
		file:close()
		return last_start_id
	end
end

elidragon.savedata.last_start_id = elidragon.savedata.last_start_id or elidragon.skyblock.load_legacy_last_start_id() or 0

-- spawns

function elidragon.skyblock.get_spawn(name)
	return elidragon.savedata.spawns[name]
end

function elidragon.skyblock.set_spawn(name, pos)
	elidragon.savedata.spawns[name] = pos
end

function elidragon.skyblock.spawn_player(player)
	if not player then return end
	local name = player:get_player_name()
	local spawn = elidragon.skyblock.get_spawn(name) or elidragon.skyblock.new_spawn(name)
	player:set_pos({x = spawn.x + 2, y = spawn.y + 2, z = spawn.z + 2})
end

function elidragon.skyblock.new_spawn(name)
	local spawn
	repeat
		elidragon.savedata.last_start_id = elidragon.savedata.last_start_id + 1
		spawn = elidragon.skyblock.start_positions[elidragon.savedata.last_start_id] 
	until not minetest.is_protected(spawn, name)
	elidragon.skyblock.set_spawn(name, spawn)	
	local file = io.open(minetest.get_modpath("elidragon") .. "/schems/island.we", "r")
	local schem = file:read()
	file:close()
	worldedit.deserialize(vector.add(spawn, {x = -3, y = -4, z = -3}), schem) 
	return spawn
end

function elidragon.skyblock.load_legacy_spawns()
    local file = io.open(minetest.get_worldpath() .. "/skyblock.spawn", "r")
    if file then
		local spawns = {}
        while true do
            local x = file:read("*n")
            if x == nil then
                break
            end
            local y = file:read("*n")
            local z = file:read("*n")
            local name = file:read("*l")
            spawns[name:sub(2)] = {x = x, y = y, z = z}
        end
        file:close()
        return spawns
	end
end

elidragon.savedata.spawns = elidragon.savedata.spawns or elidragon.skyblock.load_legacy_spawns() or {}


-- level
--[[
minetest.register_chatcommand("level", {
	description = "Get/set the current level of a player",
	params = "<player> [<level>]",
	func = function(name, param)
		local target = param:split(" ")[1]
		local level = tonumber(param:split(" ")[2])
		if not level then
			minetest.chat_send_player(name, target .. " is on level " .. elidragon.skyblock.get_level(target))
		elseif minetest.check_player_privs(name, {server = true}) and elidragon.skyblock.set_level(target, level) then
			minetest.chat_send_player(name, target .. " has been set to level " .. level)
		else
			minetest.chat_send_player(name, "Cannot change " .. target .. " to level " .. level)
		end
	end,
})
]]--

-- node

minetest.register_node("elidragon:skyblock", {
	description = "Skyblock",
	tiles = {"elidragon_quest.png"},
	paramtype = "light",
	light_source = 14,
	groups = {crumbly=2, cracky=2},
})

minetest.register_alias("skyblock:quest", "elidragon:skyblock")

-- mapgen

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname = "singlenode", water_level = -32000})
end)

-- respawn

minetest.register_on_respawnplayer(function(player)
	elidragon.skyblock.spawn_player(player)
	return true
end)

-- remove legacy cloud layer

minetest.register_lbm({
	nodenames = {"default:cloud"},
	name = "elidragon:remove_cloud_layer",
	action = function(pos)
		if pos.y == -10 then
			minetest.set_node(pos, { name = "air"})
		end
	end
})

-- remove inventory from quest block

minetest.register_lbm({
	nodenames = {"elidragon:skyblock", "skyblock:quest"},
	name = "elidragon:remove_inventory_from_quest_block",
	action = function(pos)
		minetest.get_meta(pos):set_string("formspec", "")
		minetest.get_meta(pos):set_string("infotext", "")
	end
})

-- ores

minetest.after(0, function()
	default.cool_lava = function(pos, oldnode)
		local node
		if oldnode.name == "default:lava_source" then
			node = "default:obsidian"
		elseif math.random() < 0.001 then
			node = "moreores:mineral_mithril"
		elseif math.random() < 0.003 then
			node = "default:stone_with_diamond"
		elseif math.random() < 0.005 then
			node = "default:stone_with_mese"
		elseif math.random() < 0.01 then
			node = "default:stone_with_gold"
		elseif math.random() < 0.01 then
			node = "technic:mineral_chromium"
		elseif math.random() < 0.01 then
			node = "technic:mineral_zinc"
		elseif math.random() < 0.012 then
			node = "technic:mineral_uranium"
		elseif math.random() < 0.015 then
			node = "default:stone_with_tin"
		elseif math.random() < 0.02 then
			node = "default:stone_with_copper"
		elseif math.random() < 0.025 then
			node = "technic:mineral_sulfur"
		elseif math.random() < 0.033 then
			node = "default:stone_with_iron"
		elseif math.random() < 0.04 then
			node = "moreores:mineral_silver"
		elseif math.random() < 0.045 then
			node = "technic:mineral_lead"
		elseif math.random() < 0.05 then
			node = "default:stone_with_coal"
		else
			node = "default:stone"
		end
		minetest.set_node(pos, {name = node})
		minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.25}, true)
	end
end)

-- saplings

minetest.after(0, function()
	minetest.register_alias("default:pine_leaves", "default:pine_needles")
	minetest.register_alias("default:pine_bush_leaves", "default:pine_bush_needles")
	local trees = {"default:", "default:jungle", "default:pine_", "default:acacia_", "default:aspen_", "default:bush_", "default:blueberry_bush_", "default:acacia_bush_", "default:pine_bush_", "moretrees:apple_tree_", "moretrees:beech_", "moretrees:cedar_", "moretrees:date_palm_", "moretrees:fir_", "moretrees:oak_", "moretrees:palm_", "moretrees:poplar_", "moretrees:sequoia_", "moretrees:spruce_", "moretrees:willow_", }
	for _, tree in pairs(trees) do
		local items = {}
		items[#items + 1] = {
			items = {tree .. "sapling"},
			rarity = 20,
		}
		for _, stree in pairs(trees) do
			if stree ~= tree then
				items[#items + 1] = {
					items = {stree .. "sapling"},
					rarity = 1000,
				}
			end
		end
		items[#items + 1] = {
			items = {tree .. "leaves"},
		}
		print(tree)
		minetest.registered_nodes[tree .. "leaves"].drop = {max_items = 1, items = items}
	end
end)

-- flowers

minetest.register_abm({
	nodenames = {"default:dirt_with_grass"},
	interval = 300,
	chance = 100,
	action = function(pos, node)
		pos.y = pos.y + 1
		local light = minetest.get_node_light(pos) or 0
		if minetest.get_node(pos).name == "air" and light > 12 and not minetest.find_node_near(pos, 2, {"group:flora"}) then
			local flowers = {"default:junglegrass", "default:grass_1", "flowers:dandelion_white", "flowers:dandelion_yellow", "flowers:geranium", "flowers:rose", "flowers:tulip", "flowers:tulip_black", "flowers:viola", "flowers:chrysanthemum_green"}
			minetest.set_node(pos, {name = flowers[math.random(#flowers)]})
		end
	end
})

-- recipes

minetest.register_craft({
	output = "default:desert_sand",
	recipe = {
		{"default:sand"},
		{"default:gravel"},
	}
})

minetest.register_craft({
	output = "default:desert_stone",
	recipe = {
		{"default:desert_sand", "default:desert_sand", "default:desert_sand"},
		{"default:desert_sand", "default:desert_sand", "default:desert_sand"},
		{"default:desert_sand", "default:desert_sand", "default:desert_sand"},
	}
})

minetest.register_craft({
	output = "default:sand 4",
	recipe = {
		{"default:obsidian_shard"},
	}
})

minetest.register_craft({
	output = "default:gravel 2",
	recipe = {
		{"default:cobble"},
	}
})

minetest.register_craft({
	output = "default:dirt 2",
	recipe = {
		{"default:gravel"},
	}
})

minetest.register_craft({
	output = "default:clay_lump 4",
	recipe = {
		{"default:dirt"},
	}
})

minetest.register_craft({
	output = "default:ice",
	recipe = {
		{"bucket:bucket_water"},
	}
})

minetest.register_craft({
	output = "default:snowblock 4",
	recipe = {
		{"default:ice"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "default:lava_source",
	recipe = "default:stone",
})

minetest.register_craft({
	output = "default:silver_sand 9",
	recipe = {
		{"default:sand", "default:sand", "default:sand"},
		{"default:sand", "moreores:silver_lump", "default:sand"},
		{"default:sand", "default:sand", "default:sand"},
	}
})

-- commands

minetest.register_chatcommand("set_skyblock_spawn", {
    param = "<player> <x> <y> <z>",
    desc = "Change the skyblocks spawn of a player",
    privs = {server = true},
    func = function(admin, param)
        local name = param:split(" ")[1]
        local x = tonumber(param:split(" ")[2])
        local y = tonumber(param:split(" ")[3])
        local z = tonumber(param:split(" ")[4])
        if name and x and y and z then
            elidragon.skyblock.set_spawn(name, {x = x, y = y, z = z})
        else
            minetest.chat_send_player(admin, "Invalid usage.")
        end
    end
})

minetest.register_chatcommand("island", {
	params = "",
	description = "Teleport to your Island",
	func = function(name, param)
		elidragon.skyblock.spawn_player(minetest.get_player_by_name(name))
	end,
})
