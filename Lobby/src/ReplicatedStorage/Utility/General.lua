local General = {}

General.MapTimer = 300
General.ShovelValue = 0.2
General.ChancePartDivider = 3
General.ChanceMulti = 5000

General.PrestigeBonus = {
	Speed = 5,
	Jump = 5,
	GMulti = 0.5,
	Luck = 0.5,
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
		goldValue = 100,
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