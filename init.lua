
minetest.register_node("node_mobs:frog", {
	description = "Frog",
	tiles = { "frog_top.png", "frog.png" },
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(math.random(40,60) / 100)
	end,
	on_timer = function(pos)
		local new_pos
		local upper_limit = 50 -- prevent it from wasting calculations if it's stuck
		while upper_limit > 0 do
			local ai_decision = math.random(1,100)
			if ai_decision < 80 then -- 80% to move
				upper_limit = upper_limit - 1
				--[[1 - move X+		2 - move X-
					3 - move Z+		4 - move Z-
				--]]
				local ai_decision = math.random(1,4)
				local pot_pos
				if ai_decision == 1 then
					pot_pos = {x = pos.x + 1, y = pos.y, z = pos.z}
				elseif ai_decision == 2 then
					pot_pos = {x = pos.x - 1, y = pos.y, z = pos.z}
				elseif ai_decision == 3 then
					pot_pos = {x = pos.x, y = pos.y, z = pos.z + 1}
				elseif ai_decision == 4 then
					pot_pos = {x = pos.x, y = pos.y, z = pos.z - 1}
				end

				-- Check if the potential position is air
				local pot_pos_node = minetest.get_node(pot_pos)
				if pot_pos_node.name == "air" then
					-- Potential position is air, let's continue
					i = 1
					while true do
						-- Physics: If a moving node moves over a ledge it will fall to the lowest point where there's air
						local pot_pos_belownode = minetest.get_node({ x = pot_pos.x, y = pot_pos.y - i, z = pot_pos.z })

						if pot_pos_belownode.name == "air" then
							i = i + 1
						else
							new_pos = { x = pot_pos.x, y = pot_pos.y - i + 1, z = pot_pos.z }
							break
						end
					end

					break
				else
					-- Potential position is not air, check if above node is air, in which case it'll "jump" up one node
					local pot_pos_abovenode = minetest.get_node({ x = pot_pos.x, y = pot_pos.y + 1, z = pot_pos.z })

					if pot_pos_abovenode.name == "air" then
						new_pos = { x = pot_pos.x, y = pot_pos.y + 1, z = pot_pos.z }
						break
					else
						-- Moving nodes can only jump up one node. This is more than one node, retry algorithm
					end
				end
			elseif minetest.get_node(pos).param2 ~= 1 then -- do noise because yes
				minetest.remove_node(pos)
				minetest.set_node(pos, {name = "node_mobs:frog_croaking"})
				minetest.sound_play({ name = "node_mobs_frog_noise" }, { pos = pos }, true)
				return
			end
		end

		-- Update position
		minetest.remove_node(pos)
		minetest.set_node(new_pos, {name = "node_mobs:frog"})
		--minetest.sound_play({name = "activenode_move", gain = 1}, {}, true)
	end
})

minetest.register_node("node_mobs:frog_croaking", {
	description = "Frog (Croaking)",
	tiles = { "frog_top.png", "frog_croak.png" },
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(0.25)
	end,
	on_timer = function(pos)
		minetest.remove_node(pos)
		minetest.set_node(pos, {name = "node_mobs:frog", param2 = 1 })
	end
})
