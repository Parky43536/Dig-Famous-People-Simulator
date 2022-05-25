local General = {}

General.ItemChances = {
    Mythic = 10000,
    Legendary = 3000,
    Epic = 1000,
    Rare = 500,
    Common = 100,

    GoldChestLegendary = 3000,
    GoldChestRare = 500,
    GoldChestCommon = 100,

    Crystal = 30,
    Variety = 3,
}

General.PrestigeBonus = {
	Speed = 5,
	Jump = 5,
	GMulti = 1.5,
	Luck = 1.5,
}

General.RarityData = {
	["Common"] = {
		order = 1,
		color = Color3.fromRGB(255, 255, 255),
	},

	["Rare"] = {
		order = 2,
		color = Color3.fromRGB(47, 130, 255),
	},

	["Epic"] = {
		order = 3,
		color = Color3.fromRGB(225, 0, 255),
	},

	["Legendary"] = {
		order = 4,
		color = Color3.fromRGB(255, 166, 0),
	},

	["Mythic"] = {
		order = 5,
		color = Color3.fromRGB(255, 22, 22),
	},
}

return General