local gui = require("__flib__.gui")

local lihop_Accessor = {}

--------------------------------------------------------------------------------------------------------
---------------------------------------------- Accessor GUI --------------------------------------------
--------------------------------------------------------------------------------------------------------

function lihop_Accessor.create_gui(player)
    lihop_Accessor.destroy_gui(player)
    local accessor = player.surface.find_entity("lihop-remote-accessor",player.opened.position)
    global.lihop_accessor_guis[player.index] = gui.add(player.gui.relative, {
        type = "frame",
        style_mods = { horizontally_stretchable = false },
        anchor = {
            gui = defines.relative_gui_type.container_gui,
            position = defines.relative_gui_position.top,
            name = "lihop-remote-accessor-chest"
        },
        direction = "vertical",
        children = {
            {
                type = "flow",
                style_mods = { horizontally_squashable = true },
                children = {
                    {
                        type = "label",
                        style = "subheader_caption_label",
                        rich_text_setting = "enabled",
                        style_mods = { maximal_width = 370 },
                        caption = accessor.backer_name,
                    },
                    {
                        type = "textfield",
                        visible = false,
                        style_mods = {
                            maximal_width = 0,
                            top_margin = -3,
                            right_padding = 0,
                            horizontally_stretchable = true
                        },
                        rich_text_setting = "enabled",
                        actions = {
                            on_confirmed = {
                                gui = "lihop_remote_accessor",
                                action = "rename",
                            },
                            on_text_changed = {
                                gui = "lihop_remote_accessor", action = "update_name",
                            },
                        },
                    },
                    {
                        type = "sprite-button",
                        style = "frame_action_button",
                        sprite = "utility/rename_icon_small_white",
                        tooltip = { "gui.lihop-rename-tooltip" },
                        actions = {
                            on_click = { gui = "lihop_remote_accessor", action = "rename", },
                        },
                    },
                    {
                        type = "empty-widget",
                        style = "draggable_space_header",
                        style_mods = { height = 24, horizontally_stretchable = true, right_margin = 4 },
                        ignored_by_interaction = true,
                    },
                },
            },
            {
				type = "progressbar",
				value =accessor.energy /game.entity_prototypes["lihop-remote-accessor"].electric_energy_source_prototype.buffer_capacity
			}
        }
    })
end

function lihop_Accessor.update_gui(player)
    local refs = global.lihop_accessor_guis[player.index]
    local progressbar = refs.children[2]
    local accessor = player.surface.find_entity("lihop-remote-accessor",player.opened.position)
    progressbar.value=accessor.energy /game.entity_prototypes["lihop-remote-accessor"].electric_energy_source_prototype.buffer_capacity
end

function lihop_Accessor.destroy_gui(player)
    local player_gui = global.lihop_accessor_guis[player.index]
    if player_gui and player_gui.valid then
        player_gui.destroy()
        global.lihop_accessor_guis[player.index] = nil
    end
end

function lihop_Accessor.handle_gui_action(msg, e)
    local player = game.get_player(e.player_index)
	if not player then return end
	if msg.action == "rename" then
		local refs = global.lihop_accessor_guis[player.index]
		local textfield = refs.children[1].children[2]
		local texticon = refs.children[1].children[3]
		local label = refs.children[1].children[1]
		if textfield.visible then
			textfield.visible = false
			texticon.visible = false
			label.caption = textfield.text --global.teleporteur[msg.number].name
			label.visible = true
            local accessor = player.surface.find_entity("lihop-remote-accessor",player.opened.position)
			accessor.backer_name = textfield.text
		else
            local accessor = player.surface.find_entity("lihop-remote-accessor",player.opened.position)
			textfield.text = accessor.backer_name or ""
			textfield.visible = true
			texticon.visible = true
			textfield.select_all()
			textfield.focus()
			label.visible = false
		end
	elseif msg.action == "update_name" then
        local accessor = player.surface.find_entity("lihop-remote-accessor",player.opened.position)
		accessor.backer_name = e.text ~= "" and e.text or " "
	end
end

--------------------------------------------------------------------------------------------------------
------------------------------------------------ GENERAL -----------------------------------------------

function lihop_Accessor.built(entity)
    local chest =entity.surface.create_entity { name = "lihop-remote-accessor-chest", position = entity.position, force = entity.force }
    if not global.lihop_buildings[entity.force.name] then global.lihop_buildings[entity.force.name] = {} end
	if not global.lihop_buildings[entity.force.name][entity.surface.name] then global.lihop_buildings[entity.force.name][entity.surface.name] = {} end
    if not global.lihop_buildings[entity.force.name][entity.surface.name]["accessor"] then global.lihop_buildings[entity.force.name][entity.surface.name]["accessor"] = {} end
	global.lihop_buildings[entity.force.name][entity.surface.name]["accessor"][entity.unit_number]={chest=chest,accessor=entity}


end

function lihop_Accessor.destroy(entity)
    local ent = entity.surface.find_entities_filtered { position = entity.position, name = "lihop-remote-accessor-chest" }
    if ent[1] then ent[1].destroy() end
    global.lihop_buildings[entity.force.name][entity.surface.name]["accessor"][entity.unit_number]=nil
end

function lihop_Accessor.paste_settings(source, destination)
    local chest_source=source.surface.find_entity("lihop-remote-accessor-chest",source.position)
    local chest_destination=destination.surface.find_entity("lihop-remote-accessor-chest",destination.position)
    if not chest_source then return end
    if not chest_destination then return end
    for i=1,chest_destination.request_slot_count,1 do
        chest_destination.clear_request_slot(i)
    end
    for i=1,chest_source.request_slot_count,1 do
        if chest_source.get_request_slot(i) then
            chest_destination.set_request_slot(chest_source.get_request_slot(i), i)
        end
    end

end
return lihop_Accessor
