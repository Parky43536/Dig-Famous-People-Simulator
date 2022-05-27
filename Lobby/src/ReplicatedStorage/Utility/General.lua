local General = {}

General.ShovelValue = 0.2
General.ChancePartDivider = 3

General.ItemChances = {
	Godly = 15000,
    Mythic = 7500,
    Legendary = 3000,
    Epic = 1500,
    Rare = 500,
    Common = 100,

    GoldChestLegendary = 3000,
    GoldChestRare = 500,
    GoldChestCommon = 100,

    Crystal = 50,
    Variety = 3,
}

General.ChanceLuckIgnore = {
	Crystal = true,
	Variety = true,
}

General.ChanceTotalIgnore = {
	Crystal = true,
	Variety = true,
}

General.PrestigeBonus = {
	Speed = 5,
	Jump = 5,
	GMulti = 1,
	Luck = 1,
}

General.ChestGold = {
	GoldChestLegendary = {min = 2500, max = 5000},
	GoldChestRare = {min = 500, max = 1000},
	GoldChestCommon = {min = 100, max = 200},
}

General.RarityData = {
	Common = {
		order = 1,
		color = Color3.fromRGB(255, 255, 255),
		goldValue = 50,
	},

	Rare = {
		order = 2,
		color = Color3.fromRGB(47, 130, 255),
		goldValue = 250,
	},

	Epic = {
		order = 3,
		color = Color3.fromRGB(225, 0, 255),
		goldValue = 500,
	},

	Legendary = {
		order = 4,
		color = Color3.fromRGB(255, 166, 0),
		goldValue = 1000,
	},

	Mythic = {
		order = 5,
		color = Color3.fromRGB(255, 22, 22),
		goldValue = 5000,
	},

	Godly = {
		order = 6,
		color = Color3.fromRGB(0, 225, 255),
		goldValue = 10000,
	},
}

return General