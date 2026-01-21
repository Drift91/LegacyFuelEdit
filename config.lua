Config = {}

-- Are you using ESX? Turn this to true if you would like fuel & jerry cans to cost something.
Config.UseESX = true

-- What should the price of jerry cans be?
Config.JerryCanCost = 100
Config.RefillCost = 50 -- If it is missing half of it capacity, this amount will be divided in half, and so on.

-- Fuel decor - No need to change this, just leave it.
Config.FuelDecor = "_FUEL_LEVEL"

-- What keys are disabled while you're fueling.
Config.DisableKeys = {0, 22, 23, 24, 29, 30, 31, 37, 44, 56, 82, 140, 166, 167, 168, 170, 288, 289, 311, 323}

-- Want to use the HUD? Turn this to true.
Config.EnableHUD = true

-- Want the HUD to show your speed? Turn this to true.
Config.EnableSpeedHUD = true

-- The percentage of fuel below which the HUD blinks between the below colors.
Config.LowFuelLevel = 15

-- Set the color of the HUD.
Config.ColorHUD = {r = 255, g = 255, b = 255, a = 255}

-- Set the color of the fuel section of the hud when you're low on fuel.
Config.ColorLowFuel = {r = 255, g = 50, b = 50, a = 255}

-- Use this to adjust the position of the HUD.
Config.HUDx = 0.01135
Config.HUDy = 0.002

-- Configure blips here. Turn both to false to disable blips all together.
Config.ShowNearestGasStationOnly = true
Config.ShowAllGasStations = false

-- Modify the fuel-cost here, using a multiplier value. Setting the value to 2.0 would cause a doubled increase.
Config.CostMultiplier = 1.0

-- Configure the strings as you wish here.
Config.Strings = {
	ExitVehicle = "Exit the vehicle to refuel",
	EToRefuel = "Press ~g~E ~w~to refuel vehicle",
	JerryCanEmpty = "Jerry can is empty",
	FullTank = "Tank is full",
	PurchaseJerryCan = "Press ~g~E ~w~to purchase a jerry can for ~g~$" .. Config.JerryCanCost,
	CancelFuelingPump = "Press ~g~E ~w~to cancel the fueling",
	CancelFuelingJerryCan = "Press ~g~E ~w~to cancel the fueling",
	NotEnoughCash = "Not enough cash",
	RefillJerryCan = "Press ~g~E ~w~ to refill the jerry can for ",
	NotEnoughCashJerryCan = "Not enough cash to refill jerry can",
	JerryCanFull = "Jerry can is full",
	TotalCost = "Cost",
}

if not Config.UseESX then
	Config.Strings.PurchaseJerryCan = "Press ~g~E ~w~to grab a jerry can"
	Config.Strings.RefillJerryCan = "Press ~g~E ~w~ to refill the jerry can"
end

Config.PumpModels = {
	[`prop_gas_pump_1d`] = true,
	[`prop_gas_pump_1a`] = true,
	[`prop_gas_pump_1b`] = true,
	[`prop_gas_pump_1c`] = true,
	[`prop_vintage_pump`] = true,
	[`prop_gas_pump_old2`] = true,
	[`prop_gas_pump_old3`] = true
}

-- Blacklist certain vehicles. Use names only. Be sure to use ` backticks and not quotes. https://wiki.gtanet.work/index.php?title=Vehicle_Models
Config.Blacklist = {
	--`Adder`,
	--`dilettante`,
}

-- Blacklist entire vehicle classes. https://docs.fivem.net/natives/?_0x29439776AAA00A62
Config.ClassBlacklist = {
	13, -- Cycles
	--14, -- Boats
	--15, -- Helicopters
	--16, -- Planes
	21, -- Trains
}

-- Do you want the HUD removed from showing in blacklisted vehicles?
Config.RemoveHUDForBlacklistedVehicle = true

-- Fuel usage multiplier. Lower numbers make vehicles consume less fuel.
Config.FuelUsage = 1.0

-- The rate at which fuel flows (divided by 10) from the pump or jerry can every second.
Config.RefuelRate = 1.0

-- To make jerry cans contain unlimited free fuel set this to true.
Config.UnlimitedJerryCan = false

Config.GasStations = {
	vector3(49.4187, 2778.793, 58.043),
	vector3(263.894, 2606.463, 44.983),
	vector3(1039.958, 2671.134, 39.550),
	vector3(1207.260, 2660.175, 37.899),
	vector3(2539.685, 2594.192, 37.944),
	vector3(2679.858, 3263.946, 55.240),
	vector3(2005.055, 3773.887, 32.403),
	vector3(1687.156, 4929.392, 42.078),
	vector3(1701.314, 6416.028, 32.763),
	vector3(179.857, 6602.839, 31.868),
	vector3(-94.4619, 6419.594, 31.489),
	vector3(-2554.996, 2334.40, 33.078),
	vector3(-1800.375, 803.661, 138.651),
	vector3(-1437.622, -276.747, 46.207),
	vector3(-2096.243, -320.286, 13.168),
	vector3(-724.619, -935.1631, 19.213),
	vector3(-526.019, -1211.003, 18.184),
	vector3(-70.2148, -1761.792, 29.534),
	vector3(265.648, -1261.309, 29.292),
	vector3(819.653, -1028.846, 26.403),
	vector3(1208.951, -1402.567,35.224),
	vector3(1181.381, -330.847, 69.316),
	vector3(620.843, 269.100, 103.089),
	vector3(2581.321, 362.039, 108.468),
	vector3(176.631, -1562.025, 29.263),
	vector3(176.631, -1562.025, 29.263),
	vector3(-319.292, -1471.715, 30.549),
	vector3(1784.324, 3330.55, 41.253)
}
