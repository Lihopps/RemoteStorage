local gui = require("__flib__.gui")

local lihop_Remote = {}

local allow_accessor = function(accessor)
	local ratio = 0.5
	if accessor.energy >= game.entity_prototypes["lihop-remote-accessor"].electric_energy_source_prototype.buffer_capacity * ratio then
		return true
	end
	return false
end

local allow_remote = function(player)
	if not player.get_inventory(defines.inventory.character_armor) then return end
	if not player.get_inventory(defines.inventory.character_armor)[1].valid_for_read then return end
	local remote = player.get_inventory(defines.inventory.character_armor)[1].grid.find(
		"lihop-remote-accessor-equipment")
	if remote then
		if remote.energy >= remote.max_energy * 0.2 then
			return true
		end
		return false
	end
	return false
end

function lihop_Remote.create_gui(player)
	lihop_Remote.destroy_gui(player)
	global.lihop_remote_guis[player.index] = gui.build(player.gui.relative, {
		{
			type = "frame",
			ref = { "princ" },
			style_mods = { horizontally_stretchable = false },
			name = "0",
			anchor = {
				gui = defines.relative_gui_type.controller_gui,
				position = defines.relative_gui_position.left,
			},
			direction = "vertical",
			children = {
				-- bar du haut
				{
					type = "flow",
					ref = { "titlebar" },
					children = {
						{
							type = "label",
							style = "subheader_caption_label",
							rich_text_setting = "enabled",
							style_mods = { maximal_width = 370 },
							caption = { "gui.invlist" },
						},
						{
							type = "empty-widget",
							style = "draggable_space_header",
							style_mods = { height = 24, horizontally_squashable = true },
							ignored_by_interaction = true,
						},
					},
				},
				-- frame params
				{
					type = "frame",
					style = "inside_shallow_frame",
					style_mods = { horizontally_squashable = true },
					direction = "horizontal",
					children = {
						{
							type = "frame",
							style = "inside_shallow_frame",
							style_mods = { padding = 5, },
							direction = "vertical",
							children = {
								{
									type = "label",
									caption = { "gui.surface" },

								},
								{
									type = "drop-down",
									name = "surface",
									ref = { "surface" },
									actions = {
										on_selection_state_changed = { gui = "lihop_remotePrinc", action = "change_surface" },
									},
								},
							}
						},
					}

				},
				-- frame inventory
				{
					type = "frame",
					style = "inside_shallow_frame",
					direction = "vertical",
					children =
					{
						{
							type = "scroll-pane",
							style = "scroll_pane",
							ref = { "scroll" },
							style_mods = { horizontally_stretchable = false },
							vertical_scroll_policy = "auto-and-reserve-space",
						},
					}
				}
			}
		} })
	lihop_Remote.update_gui(player, "0")
end

function lihop_Remote.update_gui(player, tick_)
	local player_gui = global.lihop_remote_guis[player.index]
	if not player_gui then return end
	local Lsurfaces = player_gui.surface
	if not Lsurfaces then return end
	Lsurfaces.clear_items()
	local index = 1

	if not global.lihop_buildings[player.force.name] then return end
	for k, v in pairs(global.lihop_buildings[player.force.name]) do
		Lsurfaces.add_item(k)

		if k == player.surface.name then
			Lsurfaces.selected_index = index
		end
		index = index + 1
	end
	local scroll = player_gui.scroll
	if (#Lsurfaces.items > 0) then
		if Lsurfaces.selected_index < 1 then
			scroll.clear()
			return
		end
		if not Lsurfaces.get_item(Lsurfaces.selected_index) then return end
		lihop_Remote.update_stock(player, game.surfaces[Lsurfaces.get_item(Lsurfaces.selected_index)], tick_)
	else
		scroll.clear()
	end
end

function lihop_Remote.update_stock(player, surface, tick_)
	local player_gui = global.lihop_remote_guis[player.index]
	if not player_gui then return end
	local scroll = player_gui.scroll --player_gui.children[3].children[1]
	scroll.clear()
	player_gui.princ.name = tostring(tick_)
	if not allow_remote(player) then --ckeck si la remote a de l'energy
		return
	end

	if not global.lihop_buildings[player.force.name][surface.name] then return end
	if not global.lihop_buildings[player.force.name][surface.name]["accessor"] then return end
	--global.lihop_buildings[entity.force.name][entity.surface.name]["accessor"][entity.unit_number]={chest=chest,accessor=entity}
	local gentable = {}
	for unit_number, data in pairs(global.lihop_buildings[player.force.name][surface.name]["accessor"]) do
		if allow_accessor(data.accessor) then --check l'accés au network
			local chest = data.chest
			if chest then
				local contents = chest.get_inventory(defines.inventory.chest).get_contents()
				local total = game.entity_prototypes["lihop-remote-accessor-chest"].get_inventory_size(defines.inventory
				.chest)
				local used = total - chest.get_inventory(defines.inventory.chest).count_empty_stacks()
				local framet =
				{
					type = "frame",
					style = "frame",
					direction = "vertical",
					ref = { data.accessor.backer_name },
					style_mods = { horizontally_stretchable = true },
					children = {
						{
							type = "flow",
							direction = "horizontal",
							style_mods = { horizontally_stretchable = true, vertical_align = "center" },
							children = {
								{
									type = "sprite-button",
									style = "tool_button",
									sprite = "utility/map",
									tooltip = { "gui.showonmap" },
									actions = {
										on_click = { gui = "lihop_remotePrinc", action = "move_cam", surf = surface.name, pos = chest.position },
									},

								},
								{
									type = "label",
									caption = data.accessor.backer_name .. "  " .. used .. "/" .. total
								},
								{
									type = "progressbar",
									value = data.accessor.energy /
										game.entity_prototypes["lihop-remote-accessor"]
										.electric_energy_source_prototype.buffer_capacity
								}
							}
						},
						{
							type = "table",
							style = "slot_table",
							name = "item",
							ref = { data.accessor.backer_name .. "table" },
							column_count = 10,
						},
					},
				}
				local tablet = framet.children[2]
				for k, v in pairs(contents) do
					local button = {
						type = "sprite-button",
						number = v,
						sprite = "item/" .. k,
						name = k,
						ref = { k },
						tooltip = { "gui.transferttooltip" },
						actions = {
							on_click = { ref = k, gui = "lihop_remotePrinc", action = "give_item", itemStack = { item = k, qty = v }, surf = surface.name, pos = chest.position },
						},
					}
					--gui.build(table,button)
					table.insert(tablet, button)
				end
				table.insert(gentable, framet)
			end
		end
	end
	gui.build(scroll, gentable)
end

function lihop_Remote.destroy_gui(player)
	local player_gui = global.lihop_remote_guis[player.index]
	global.lihop_remote_guis[player.index] = nil
	if player_gui then
		if player_gui.princ then
			player_gui.princ.destroy()
		end
	end
	--gui.clear_completed(defines.relative_gui_type.controller_gui)
	if player_gui then
		--player_gui.destroy()
	end
end

function lihop_Remote.handle_gui_action(msg, e)
	if msg.action == "change_surface" then
		local player = game.get_player(e.player_index)
		if not player then return end
		if not player.opened_gui_type == defines.gui_type.entity then
			return
		end
		local player_gui = global.lihop_remote_guis[player.index]
		local Lsurfaces = player_gui.surface
		lihop_Remote.update_stock(player, game.surfaces[Lsurfaces.get_item(Lsurfaces.selected_index)], e.tick)
	elseif msg.action == "give_item" then
		local player = game.get_player(e.player_index)
		if not player then return end
		if not player.opened_gui_type == defines.gui_type.entity then
			return
		end
		local qty = 1
		if e.shift then
			if game.item_prototypes[msg.itemStack.item].stack_size <= msg.itemStack.qty then
				qty = game.item_prototypes[msg.itemStack.item].stack_size
			else
				qty = msg.itemStack.qty
			end
		end
		if true then -- check si le player peut prendre les objets
			local realins = player.insert({ name = msg.itemStack.item, count = qty })
			if realins < 1 then
				game.print("Not enough place")
				return
			end
			local entity = game.surfaces[msg.surf].find_entity("lihop-remote-accessor-chest", msg.pos)
			if not entity then return end
			entity.get_inventory(defines.inventory.chest).remove({
				name = msg.itemStack.item,
				count = realins
			})
			local player_gui = global.lihop_remote_guis[player.index]

			lihop_Remote.update_stock(player, game.surfaces[msg.surf], e.tick)
		end
	elseif msg.action == "move_cam" then
		local player = game.get_player(e.player_index)
		if not player then return end
		player.open_map(msg.pos)
	end
end

return lihop_Remote
