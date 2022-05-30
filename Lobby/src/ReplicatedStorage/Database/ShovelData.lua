local ShovelData = {
	["Default Shovel"] = {
		id = 1,
		Cost = 0,
		Stats = {
			Reload = 1.5,
			Dig = 7,
			Speed = 16,
			Jump = 7.2,
			GMulti = 1,
			Luck = 1,
		}
	},

	["Great Shovel"] = {
		id = 2,
		Cost = 2500,
		Color = Color3.fromRGB(201, 166, 90),
		Stats = {
			Reload = 1.4,
			Dig = 7.5,
			Speed = 16.5,
			Jump = 7.5,
			GMulti = 1.1,
			Luck = 1.1,
		}
	},

	["Super Shovel"] = {
		id = 3,
		Cost = 5000,
		Color = Color3.fromRGB(226, 64, 64),
		Stats = {
			Reload = 1.3,
			Dig = 8,
			Speed = 17,
			Jump = 8,
			GMulti = 1.2,
			Luck = 1.2,
		}
	},

	["Super Light Shovel"] = {
		id = 4,
		Cost = 10000,
		Color = Color3.fromRGB(221, 114, 114),
		Stats = {
			Reload = 1.2, --less 0.1
			Dig = 8, --same
			Speed = 20, --more 3
			Jump = 10, --more 2
			GMulti = 1.2, --same
			Luck = 1.4, --more 0.2
		}
	},

	["Super Heavy Shovel"] = {
		id = 5,
		Cost = 12500,
		Color = Color3.fromRGB(170, 49, 49),
		Stats = {
			Reload = 1.5, --default
			Dig = 10, --more 2
			Speed = 16, --default
			Jump = 7.2, --default
			GMulti = 1.4, --more 0.2
			Luck = 1.2, --same
		}
	},

	["Mega Shovel"] = {
		id = 6,
		Cost = 25000,
		Color = Color3.fromRGB(69, 226, 64),
		Stats = {
			Reload = 1.2,
			Dig = 9,
			Speed = 18,
			Jump = 9,
			GMulti = 1.4,
			Luck = 1.4,
		}
	},

	["Mega Light Shovel"] = {
		id = 7,
		Cost = 35000,
		Color = Color3.fromRGB(123, 221, 114),
		Stats = {
			Reload = 1.1,
			Dig = 9,
			Speed = 23,
			Jump = 13,
			GMulti = 1.4,
			Luck = 1.6,
		}
	},

	["Mega Heavy Shovel"] = {
		id = 8,
		Cost = 37500,
		Color = Color3.fromRGB(63, 170, 49),
		Stats = {
			Reload = 1.5,
			Dig = 11,
			Speed = 16,
			Jump = 7.2,
			GMulti = 1.6,
			Luck = 1.4,
		}
	},

	["Ultra Shovel"] = {
		id = 6,
		Cost = 60000,
		Color = Color3.fromRGB(64, 67, 226),
		Stats = {
			Reload = 1.1,
			Dig = 10,
			Speed = 20,
			Jump = 10,
			GMulti = 1.6,
			Luck = 1.6,
		}
	},

	["Ultra Light Shovel"] = {
		id = 7,
		Cost = 72500,
		Color = Color3.fromRGB(121, 114, 221),
		Stats = {
			Reload = 1,
			Dig = 10,
			Speed = 26,
			Jump = 16,
			GMulti = 1.6,
			Luck = 1.8,
		}
	},

	["Ultra Heavy Shovel"] = {
		id = 8,
		Cost = 75000,
		Color = Color3.fromRGB(51, 49, 170),
		Stats = {
			Reload = 1.5,
			Dig = 12,
			Speed = 16,
			Jump = 7.2,
			GMulti = 1.8,
			Luck = 1.6,
		}
	},

	["Supreme Shovel"] = {
		id = 9,
		Cost = 100000,
		Color = Color3.fromRGB(139, 41, 148),
		Stats = {
			Reload = 1,
			Dig = 10,
			Speed = 20,
			Jump = 10,
			GMulti = 2,
			Luck = 2,
		}
	},

	["Adurite Shovel"] = {
		id = 10,
		Cost = 250000,
		Color = Color3.fromRGB(136, 0, 0),
		Special = "Bomb Resistance",
		Stats = {
			Reload = 1.2,
			Dig = 13,
			Speed = 18,
			Jump = 9,
			GMulti = 2.5,
			Luck = 2,
		}
	},

	["Bombastic Shovel"] = {
		id = 11,
		Cost = 500000,
		Color = Color3.fromRGB(255, 115, 0),
		Special = "More Bombs",
		Stats = {
			Reload = 1.5,
			Dig = 15,
			Speed = 16,
			Jump = 10,
			GMulti = 2.5,
			Luck = 2.5,
		}
	},

	["Aurora Shovel"] = {
		id = 13,
		Cost = 750000,
		Color = Color3.fromRGB(0, 255, 179),
		Special = "Double Jump",
		Stats = {
			Reload = 1.3,
			Dig = 13,
			Speed = 20,
			Jump = 20,
			GMulti = 2.5,
			Luck = 3,
		}
	},


	["Electric Shovel"] = {
		id = 14,
		Cost = 800000,
		Color = Color3.fromRGB(0, 217, 255),
		Special = "Double Speed",
		Stats = {
			Reload = 0.9,
			Dig = 11,
			Speed = 20,
			Jump = 20,
			GMulti = 3,
			Luck = 3,
		}
	},

	["Abstract Shovel"] = {
		id = 15,
		Cost = 850000,
		Color = Color3.fromRGB(0, 26, 255),
		Special = "Half Reload",
		Stats = {
			Reload = 1.2,
			Dig = 10,
			Speed = 18,
			Jump = 9,
			GMulti = 3,
			Luck = 3.5,
		}
	},

	["Bluesteel Shovel"] = {
		id = 16,
		Cost = 900000,
		Color = Color3.fromRGB(166, 190, 255),
		Special = "Double Dig",
		Stats = {
			Reload = 1.5,
			Dig = 9,
			Speed = 18,
			Jump = 9,
			GMulti = 3.5,
			Luck = 3.5,
		}
	},

	["Emerald Shovel"] = {
		id = 17,
		Cost = 1000000,
		Color = Color3.fromRGB(9, 255, 0),
		Special = "Double Luck",
		Stats = {
			Reload = 1,
			Dig = 10,
			Speed = 20,
			Jump = 10,
			GMulti = 3.5,
			Luck = 2.5,
		}
	},

	["Golden Shovel"] = {
		id = 18,
		Cost = 1500000,
		Color = Color3.fromRGB(255, 238, 0),
		Special = "Double G Multi",
		Stats = {
			Reload = 1,
			Dig = 10,
			Speed = 20,
			Jump = 10,
			GMulti = 2.5,
			Luck = 3.5,
		}
	},

	["Galactic Shovel"] = {
		id = 19,
		Cost = 2000000,
		Color = Color3.fromRGB(159, 0, 173),
		Special = "Flight",
		Stats = {
			Reload = 0.8,
			Dig = 12,
			Speed = 20,
			Jump = 10,
			GMulti = 4,
			Luck = 4,
		}
	},

	["Godly Shovel"] = {
		id = 20,
		Cost = 10000000,
		Color = Color3.fromRGB(255, 255, 255),
		Special = "All Specials",
		Stats = {
			Reload = 1.2,
			Dig = 10,
			Speed = 25,
			Jump = 15,
			GMulti = 3,
			Luck = 3,
		}
	},
}
return ShovelData
