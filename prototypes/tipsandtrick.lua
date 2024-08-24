local simulations = {}

data:extend({
	{
		type = "tips-and-tricks-item-category",
		name = "lihop-remote-tt-category",
		order = "l-[Remote]",
	},
	{
		type = "tips-and-tricks-item",
		name = "lihop-remote-access",
		category = "lihop-remote-tt-category",
		order = "0",
		starting_status = "locked",
		trigger =
		{
			type = "research",
			technology = "lihop-remote-access"
		},
		tag = "[item=lihop-remote-accessor-equipment]",
		is_title = true,
		image = "__RemoteStorage__/graphics/tips-and-tricks/remote.png",
		--simulation = simulations.pipette
	},
})
