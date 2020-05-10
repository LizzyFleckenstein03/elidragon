minetest.register_alias_force("default:sign_yard", "default:sign_wood_yard")
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, player)
	if pos.y <= -7 then
		return true
	else
		return old_is_protected(pos, player)
	end	
end
minetest.register_abm({
	nodenames = {"air"},
	neighbors = {"default:cloud"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
        if pos.y == -10 then
            minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, {name = "default:cloud"})
        end
	end
})
