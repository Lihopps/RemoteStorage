local gui = require("__flib__.gui")
local migration = require("__flib__.migration")

local lihop_remote = require("script.RemotePrinc")
local lihop_accessor = require("script.Accessor")
local migrations = require("script.migrations")





--BOOTSTRAP

script.on_init(function()
	-- Initialize libraries

	-- create a table to store building needed in control
	if not global.lihop_buildings then global.lihop_buildings= {} end
	if not global.lihop_buildings_version then global.lihop_buildings_version=1 end

	global.lihop_remote_guis = {}
	global.lihop_accessor_guis = {}
end)


script.on_configuration_changed(function(e)
	if not global.lihop_buildings then global.lihop_buildings= {} end
	migration.on_config_changed(e, migrations.versions)

	if not global.lihop_remote_guis then global.lihop_remote_guis = {} end
	if not global.lihop_accessor_guis then global.lihop_accessor_guis = {} end
end)

--------------------------------------------------------------------------------------------------------
------------------------------------------- EVENT Surface -----------------------------------------------
--------------------------------------------------------------------------------------------------------

script.on_event({
	defines.events.on_surface_cleared,
	defines.events.on_surface_deleted,
}, function(e)
	for forcename,datforce in pairs(global.lihop_buildings) do
		for surfname,datsurf in pairs(global.lihop_buildings[forcename]) do
			if game.surfaces[surfname].index==e.surface_index then
				global.lihop_buildings[forcename][surfname]=nil
			end
		end
	end
end)

script.on_event({
	defines.events.on_surface_renamed,
}, function(e)
	for forcename,datforce in pairs(global.lihop_buildings) do
		global.lihop_buildings[forcename][e.new_name]=global.lihop_buildings[forcename][e.old_name]
		global.lihop_buildings[forcename][e.old_name]=nil
	end
end)

--------------------------------------------------------------------------------------------------------
------------------------------------------- EVENT ENTITY -----------------------------------------------
--------------------------------------------------------------------------------------------------------

script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}, function(e)
	local entity = e.entity or e.created_entity
	local constructeur = nil
	if e.player_index then
		constructeur = game.players[e.player_index]
	else
		constructeur = e.robot
	end
	if not entity or not entity.valid then
		return
	end
	if not constructeur or not constructeur.valid then
		return
	end
	local entity_name = entity.name
	if entity_name == "lihop-remote-accessor" then
		lihop_accessor.built(entity)
	end
end)

script.on_event({
	defines.events.on_pre_player_mined_item,
	defines.events.on_robot_pre_mined,
	defines.events.on_entity_died,
	defines.events.script_raised_destroy,
}, function(e)
	local entity = e.entity
	if not entity or not entity.valid then
		return
	end
	local entity_name = entity.name
	if entity_name == "lihop-remote-accessor" then
		lihop_accessor.destroy(entity)
	end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(e)
	local player = game.get_player(e.player_index)
	local source = e.source
	local destination = e.destination
	if not source then return end
	if not destination then return end
	if (source.name == "lihop-remote-accessor") and (destination.name == "lihop-remote-accessor") then
		lihop_accessor.paste_settings(source, destination)
	end
end)

--------------------------------------------------------------------------------------------------------
--------------------------------------------- GUI ------------------------------------------------------
--------------------------------------------------------------------------------------------------------

local function handle_gui_event(e)
	local msg = gui.read_action(e)
	if msg then
		if msg.gui == "lihop_remotePrinc" then
			lihop_remote.handle_gui_action(msg, e)
		elseif msg.gui == "lihop_remote_accessor" then
			lihop_accessor.handle_gui_action(msg, e)
		end
		return true
	end
	return false
end

gui.hook_events(handle_gui_event)

--------------------------------------------------------------------------------------------------------
------------------------------------------ PLAYER ------------------------------------------------------
--------------------------------------------------------------------------------------------------------

script.on_nth_tick(20, function(e)
	for k, v in pairs(game.players) do
		if not v then return end
		if v.opened_self then
			local player_gui = global.lihop_remote_guis[v.index]
			if player_gui then
				if e.tick-tonumber(player_gui.princ.name)>=20 then
					local Lsurfaces = player_gui.surface
					if (#Lsurfaces.items > 0) then
						if Lsurfaces.selected_index<1 then return end
						if not Lsurfaces.get_item(Lsurfaces.selected_index) then return end
						lihop_remote.update_stock(v, game.surfaces[Lsurfaces.get_item(Lsurfaces.selected_index)],e.tick)
					end
				end
			end
		elseif v.opened then
			if v.opened_gui_type == defines.gui_type.entity then
				if v.opened.name == "lihop-remote-accessor-chest" then
					lihop_accessor.update_gui(v)
				end
			end
		end
	end
end)

script.on_event(defines.events.on_gui_opened, function(e)
	if e.gui_type == 3 then
		local player = game.players[e.player_index]
		if global.lihop_remote_guis[player.index] then
			--lihop_remote.create_gui(player)
			lihop_remote.update_gui(player,e.tick)
		elseif player.get_inventory(defines.inventory.character_armor) then
			if player.get_inventory(defines.inventory.character_armor)[1].valid_for_read then
				if player.get_inventory(defines.inventory.character_armor)[1].grid.count("lihop-remote-accessor-equipment") > 0 then
					lihop_remote.create_gui(player)
				end
			end
		end
	end
	if e.entity then
		if e.entity.name == "lihop-remote-accessor" then
			local player = game.players[e.player_index]
			if not player then return end
			local ent = player.surface.find_entity("lihop-remote-accessor-chest", e.entity.position)
			if ent and ent.valid then
				player.opened = ent
				lihop_accessor.create_gui(player)
			end
		end
	end
end)

script.on_event(defines.events.on_gui_closed, function(e)
	if e.entity then
		if e.entity.name == "lihop-remote-accessor-chest" then
			local player = game.players[e.player_index]
			if not player then return end
			lihop_accessor.destroy_gui(player)
		end
	end
end)

script.on_event({
	defines.events.on_player_armor_inventory_changed,
	defines.events.on_player_removed_equipment,
	defines.events.on_player_placed_equipment,
}, function(e)
	local player = game.players[e.player_index]
	if player.get_inventory(defines.inventory.character_armor)[1].valid_for_read then
		if player.get_inventory(defines.inventory.character_armor)[1].grid.count("lihop-remote-accessor-equipment") == 0 then
			lihop_remote.destroy_gui(player)
			return
		end
		if not global.lihop_remote_guis[player.index] then
			if player.get_inventory(defines.inventory.character_armor)[1].valid_for_read then
				if player.get_inventory(defines.inventory.character_armor)[1].grid.count("lihop-remote-accessor-equipment") > 0 then
					lihop_remote.create_gui(player)
					return
				end
			end
		end
	else
		lihop_remote.destroy_gui(player)
	end
end)


script.on_event(defines.events.on_player_created, function(e)

end)

script.on_event(defines.events.on_player_removed, function(e)
	local player = game.get_player(e.player_index)
	if not player then
		return
	end
	lihop_remote.destroy_gui(player)
end)
