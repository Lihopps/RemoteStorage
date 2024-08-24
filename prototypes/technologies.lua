
local prerequisite= {"logistic-system","fusion-reactor-equipment"}
if mods["space-exploration"] then
	prerequisite={"logistic-system","se-thruster-suit-2"}
end


data:extend({
	{
		type = "technology",
		name= "lihop-remote-access",
		icon_size = 256, icon_mipmaps = 4,
		icons= 
		{
			{
				icon="__RemoteStorage__/graphics/technology/remote-access.png"
			}
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "lihop-remote-accessor"
			},
			{
				type = "unlock-recipe",
				recipe = "lihop-remote-accessor-equipment"
			}
		},
		unit =
		{
			count = 300,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 30
		},
		prerequisites = prerequisite
	},
})