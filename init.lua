elidragon = {}

local modules = {"functions", "nodes", "commands", "ranks", "tags", "warps", "misc", "patches", "birthday", "skyblock"}

local modpath = minetest.get_modpath("elidragon")

for _, module in pairs(modules) do
    dofile(modpath .. "/" .. module .. ".lua")
end