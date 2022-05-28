local ChanceData = {
	["Godly"] = {
		chance = 15000,
	},
	["Mythic"] = {
		chance = 10000,
	},
	["Legendary"] = {
		chance = 5000,
	},
	["Epic"] = {
		chance = 1500,
	},
	["Rare"] = {
		chance = 500,
	},
	["Common"] = {
		chance = 100,
	},
	--------------------------
	["GoldChestLegendary"] = {
		chance = 5000,
	},
	["GoldChestRare"] = {
		chance = 500,
	},
	["GoldChestCommon"] = {
		chance = 100,
	},
	--------------------------
	["SpeedPowerUp"] = {
		chance = 2000,
		ignoreLuck = true,
		duration = 30,
		value = 5,
	},
	["JumpPowerUp"] = {
		chance = 2000,
		ignoreLuck = true,
		duration = 30,
		value = 5,
	},
	["GMultiPowerUp"] = {
		chance = 2000,
		ignoreLuck = true,
		duration = 30,
		value = 0.25,
	},
	["LuckPowerUp"] = {
		chance = 2000,
		ignoreLuck = true,
		duration = 30,
		value = 0.25,
	},
	--------------------------
	["Bomb"] = {
		chance = 900,
		ignoreLuck = true,
		playerOnly = true,
		size = 20,
		damage = 60,
	},
	["Crystal"] = {
		chance = 100,
		ignoreLuck = true,
		ignoreTotal = true,
	},
	["Variety"] = {
		chance = 5,
		ignoreLuck = true,
		ignoreTotal = true,
		dontBreak = true,
	},
}
return ChanceData
