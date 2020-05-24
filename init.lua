elidragon = {}

local modules = {"functions", "nodes", "commands", "ranks", "tags", "warps", "misc", "birthday", "skyblock", "playerlist", "quests"}

local modpath = minetest.get_modpath("elidragon")

for _, module in pairs(modules) do
    dofile(modpath .. "/" .. module .. ".lua")
end
