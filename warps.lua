elidragon.warps = {
    {
        name = "shop",
        desc = "Shop",
        pos = {x = 0, y = 1000.5, z = 0}
    },
    {
        name = "hub",
        desc = "Hub",
        pos = {x = 10071, y = 10003, z = 9951},
    },
    {
        name = "spawn",
        desc = "Spawn",
        pos = {x = -21, y = 10202.5, z = -5},
        restricted = true
    },
} 
for _, warp in pairs(elidragon.warps) do
    local desc = "Warp to " .. warp.desc
    if warp.restricted then
        desc = desc .. " [only for staff members]"
    end
    minetest.register_chatcommand(warp.name, {
        description = desc,
        privs = {teleport = warp.restricted},
        func = function(name)
            local player = minetest.get_player_by_name(name)
            if player then
                player:set_pos(warp.pos)
            end
        end
    })
end
