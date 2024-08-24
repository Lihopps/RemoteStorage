local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")

local empty = {
  filename = "__core__/graphics/empty.png",
  priority = "medium",
  width = 1,
  height = 1,
  frame_count = 1,
  line_length = 1,
}

data:extend({
  {
    type = "recipe",
    name = "lihop-remote-accessor",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      { "concrete",         100 },
      { "steel-plate",      50 },
      { "advanced-circuit", 100 },
      { "radar",  5 },
      { "roboport",  2 }
    },
    result = "lihop-remote-accessor",
    requester_paste_multiplier = 10
  },
  {
    type = "item",
    name = "lihop-remote-accessor",
    icon = "__RemoteStorage__/graphics/entities/lihop-remote-accessor/lihop-remote-accessor-icon.png",
    icon_size = 64,
    icon_mipmaps = 4,
    place_result = "lihop-remote-accessor",
    subgroup = "logistic-network",
    order = "d",
    stack_size = 50
  },
  {
    type = "roboport",
    name = "lihop-remote-accessor",
    icon = "__RemoteStorage__/graphics/entities/lihop-remote-accessor/lihop-remote-accessor-icon.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = { "placeable-player", "player-creation" },
    minable = { mining_time = 0.1, result = "lihop-remote-accessor" },
    max_health = 500,
    collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    drawing_box = { { -1.5, -1.7 }, { 1.5, 1.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    alert_icon_shift = util.by_pixel(0, 0),
    resistances =
    {
      {
        type = "fire",
        percent = 60
      },
      {
        type = "impact",
        percent = 30
      }
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = "5MW",
      buffer_capacity = "100MJ"
    },
    recharge_minimum = "40MJ",
    energy_usage = "150kW",
    -- per one charge slot
    charging_energy = "1000kW",
    logistics_radius = 3,
    construction_radius = 0,
    charge_approach_distance = 5,
    robot_slots_count = 0,
    material_slots_count = 0,
    stationing_offset = { 0, 0 },
    charging_offsets =
    {
      { -1.5, -0.5 }, { 0, -0.5 }, { 1.5, -0.5 }, { 1.5, 1.5 }, { 0, 1.5 }, { -1.5, 1.5 }
    },
    base =
    {
      layers = { empty }
    },
    base_patch = empty,
    base_animation =
    {
      filename = "__RemoteStorage__/graphics/entities/lihop-remote-accessor/lihop-remote-accessor.png",
      priority = "high",
      width = 422,
      height = 303,
      frame_count = 16,
      line_length = 4,
      shift = util.by_pixel(30, 0),
      scale = 0.5,
    },
    door_animation_up = empty,
    door_animation_down = empty,
    recharging_animation =
    {
      filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
      draw_as_glow = true,
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.5,
      animation_speed = 0.5,
    },
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound =
    {
      sound = { filename = "__base__/sound/roboport-working.ogg", volume = 0.4 },
      max_sounds_per_type = 3,
      audible_distance_modifier = 0.75,
      --probability = 1 / (5 * 60) -- average pause between the sound is 5 seconds
    },
    recharging_light = { intensity = 0.2, size = 3, color = { r = 0.5, g = 0.5, b = 1.0 } },
    request_to_open_door_timeout = 15,
    spawn_and_station_height = -0.1,
    draw_logistic_radius_visualization = true,
    draw_construction_radius_visualization = true,
  },
  {
    type = "logistic-container",
    name = "lihop-remote-accessor-chest",
    icon = "__base__/graphics/icons/logistic-chest-buffer.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = { "placeable-player", "player-creation","not-blueprintable" },
    minable = { mining_time = 0.1, result = "lihop-remote-accessor" },
    max_health = 500,
    inventory_size = 96,
    logistic_mode = "requester",
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
    selection_box = { { 0, 0 }, { 0, 0 } },
    drawing_box = { { -1.5, -1.7 }, { 1.5, 1.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    placeable_by = { item = "lihop-remote-accessor", count = 1 },
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "impact",
        percent = 60
      }
    },
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    animation_sound = sounds.logistics_chest_open,
    vehicle_impact_sound = sounds.generic_impact,
    opened_duration = logistic_chest_opened_duration,
    animation =
    {
      layers =
      {
        {
          filename = "__RemoteStorage__/graphics/entities/lihop-remote-accessor/lihop-remote-accessor.png",
          priority = "high",
          flags={"low-object"},
          width = 422,
          height = 303,
          frame_count = 16,
          line_length = 4,
          shift = util.by_pixel(30, 0),
          scale = 0.5,
        },
      }
    },
  },
})
