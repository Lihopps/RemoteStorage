data:extend({
    {
      type = "item",
      name = "lihop-remote-accessor-equipment",
      icon = "__RemoteStorage__/graphics/items/remote.png",
      icon_size = 64,
      icon_mipmaps = 4,
      subgroup = "equipment",
      order = "g",
      placed_as_equipment_result = "lihop-remote-accessor-equipment",
      default_request_amount = 1,
      stack_size = 1,
    },
    {
      type = "recipe",
      name = "lihop-remote-accessor-equipment",
      enabled = true,
      energy_required = 10,
      ingredients =
      {
        { "fusion-reactor-equipment", 1 },
        { "radar", 2 },
        { "battery", 5 }
      },
      result = "lihop-remote-accessor-equipment"
    },
     {
    type = "battery-equipment",
    name = "lihop-remote-accessor-equipment",
    sprite =
    {
      filename = "__RemoteStorage__/graphics/items/remote-equipment.png",
      width = 64,
      height = 64,
      priority = "medium",
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
     energy_source =
    {
      type = "electric",
      buffer_capacity = "200kJ",
      input_flow_limit = "450kW",
      usage_priority = "primary-input",
      drain = "400kW",
    },
    categories = {"armor"}
  },
})