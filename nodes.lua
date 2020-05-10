local nodes = {
    {"Fleckenstein", "default_cloud.png^elidragon_fleckenstein.png", "ef"},
    {"DerZombiiie", "elidragon_derzombiiie.png", "dz"},
    {"Elidragon", "elidragon.png", "e"},
    {"TheodorSmall", "elidragon_theodor_small.png", "ts"},
    {"HimbeerserverDE", "elidragon_himbeerserver.png", "hs"},
    {"SC++", "elidragon_scpp.png", "scpp"},
    {"Anton", "elidragon_anton.png", "a"},
    {"Max Glueckstaler", "elidragon_max_glueckstaler.png", "mg"},
    {"Olliy", "elidragon_olliy.png", "o"},
    {"Island", "elidragon_island.png", "sky"},
    {"Python", "default_rainforest_litter.png^elidragon_python.png", "py"},
    {"Tux", "default_ice.png^elidragon_tux.png", "tux"},
}
for _, def in pairs(nodes) do
    local name = "elidragon:" .. string.lower(def[1]):gsub("+", "p"):gsub(" ", "_")
    minetest.register_node(name, {
        description = def[1] .. " Block",
        tiles = {def[2]},
		groups = {oddly_breakable_by_hand = 1, choppy = 1},
        stack_max = 1,
    })
    if def[3] then
		minetest.register_alias("elidragon_server:" .. def[3] .. "block", name)
    end
end
