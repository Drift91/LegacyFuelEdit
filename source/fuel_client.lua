if Config.UseESX then
	Citizen.CreateThread(function()
		while not ESX do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

			Citizen.Wait(500)
		end
	end)
end

local isNearPump = false
local isFueling = false
local currentFuel = 0.0
local currentCost = 0.0
local currentCash = 1000
local fuelSynced = false
local inBlacklisted = false
local tweening = false
local tweenObj = {v = 0.0}

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(400, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		local petrolVolume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
		--local enginePower = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveForce')
		
		SetFuel(vehicle, GetFuel(vehicle) - (Config.FuelUsage or 1.0) * GetVehicleCurrentRpm(vehicle) * lerp(0.1, 1.0, GetVehicleThrottleOffset(vehicle)) * 5 / petrolVolume)
	end
end

Citizen.CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)

	while true do
		Citizen.Wait(1000)

		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped)

			if TableContains(Config.Blacklist, GetEntityModel(vehicle)) or TableContains(Config.ClassBlacklist, GetVehicleClass(vehicle)) then
				inBlacklisted = true
			else
				inBlacklisted = false
			end

			if not inBlacklisted and GetPedInVehicleSeat(vehicle, -1) == ped then
				ManageFuelUsage(vehicle)
			end
		else
			if fuelSynced then
				fuelSynced = false
			end

			if inBlacklisted then
				inBlacklisted = false
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(250)

		local pumpObject, pumpDistance = FindNearestFuelPump()

		if pumpDistance < 3.5 then
			isNearPump = pumpObject

			if Config.UseESX then
				local playerData = ESX.GetPlayerData()
				for i=1, #playerData.accounts, 1 do
					if playerData.accounts[i].name == 'money' then
						currentCash = playerData.accounts[i].money
						break
					end
				end
			end
		else
			isNearPump = false

			Citizen.Wait(1000)
		end
	end
end)

AddEventHandler('fuel:startFuelUpTick', function(pumpObject, ped, vehicle)
	currentFuel = GetFuel(vehicle)
	local petrolVolume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')

	while isFueling do
		Citizen.Wait(500)

		local oldFuel = DecorGetFloat(vehicle, Config.FuelDecor)
		local fuelToAdd = math.random(18, 20) * Config.RefuelRate * 5 / petrolVolume
		local extraCost = fuelToAdd / 1.5 * Config.CostMultiplier * petrolVolume / 5

		if not pumpObject then
			if Config.UnlimitedJerryCan then
				currentFuel = oldFuel + fuelToAdd

			elseif GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100 >= 0 then
				currentFuel = oldFuel + fuelToAdd

				SetPedAmmo(ped, 883325847, math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 12 * petrolVolume / 5))
			else
				isFueling = false
			end
		else
			currentFuel = oldFuel + fuelToAdd
		end

		if currentFuel > 100.0 then
			currentFuel = 100.0
			isFueling = false
		end

		currentCost = currentCost + extraCost

		if currentCash >= currentCost then

			local loop = 0
			while loop < 500 and not NetworkHasControlOfEntity(vehicle) do
				NetworkRequestControlOfEntity(vehicle)

				loop = loop + 1
				Citizen.Wait(1)
			end

			SetFuel(vehicle, currentFuel)
		else
			isFueling = false
		end
	end

	if pumpObject then
		TriggerServerEvent('fuel:pay', currentCost)
	end

	currentCost = 0.0
end)

AddEventHandler('fuel:refuelFromPump', function(pumpObject, ped, vehicle)
	TaskTurnPedToFaceEntity(ped, vehicle, 1000)
	Citizen.Wait(1000)
	SetCurrentPedWeapon(ped, -1569615261, true)
	LoadAnimDict("timetable@gardener@filling_can")
	TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

	TriggerEvent('fuel:startFuelUpTick', pumpObject, ped, vehicle)

	while isFueling do
		for _, controlIndex in pairs(Config.DisableKeys) do
			DisableControlAction(0, controlIndex)
		end

		local vehicleCoords = GetEntityCoords(vehicle)

		if pumpObject then
			local stringCoords = GetEntityCoords(pumpObject)
			local extraString = ""

			if Config.UseESX then
				extraString = "\n" .. Config.Strings.TotalCost .. ": ~g~$" .. Round(currentCost, 1)
			end

			DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.CancelFuelingPump .. extraString)
			DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, Round(currentFuel, 1) .. "%")
		elseif Config.UnlimitedJerryCan then
			DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, Config.Strings.CancelFuelingJerryCan .. "\n" .. Round(currentFuel, 1) .. "%")
		else
			DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, Config.Strings.CancelFuelingJerryCan .. "\nGas can: ~g~" .. Round(GetAmmoInPedWeapon(ped, 883325847) / 4500 * 100, 1) .. "%~w~ | Vehicle: ~g~" .. Round(currentFuel, 1) .. "%")
		end

		if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
			TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
		end

		if IsControlJustReleased(0, 38) or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) or (isNearPump and GetEntityHealth(pumpObject) <= 0) then
			isFueling = false
		end

		Citizen.Wait(0)
	end

	ClearPedTasks(ped)
	RemoveAnimDict("timetable@gardener@filling_can")
end)

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()

		if not isFueling and ((isNearPump and GetEntityHealth(isNearPump) > 0) or (GetSelectedPedWeapon(ped) == 883325847 and not isNearPump)) then
			if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
				local pumpCoords = GetEntityCoords(isNearPump)

				DrawText3Ds(pumpCoords.x, pumpCoords.y, pumpCoords.z + 1.2, Config.Strings.ExitVehicle)
			else
				local vehicle = GetPlayersLastVehicle()
				local vehicleCoords = GetEntityCoords(vehicle)

				if DoesEntityExist(vehicle) and #(GetEntityCoords(ped) - vehicleCoords) < 2.5 then
					if not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
						local stringCoords = GetEntityCoords(isNearPump)
						local canFuel = true

						if GetSelectedPedWeapon(ped) == 883325847 then
							stringCoords = vehicleCoords

							if GetAmmoInPedWeapon(ped, 883325847) < 100 then
								canFuel = false
							end
						end

						if GetFuel(vehicle) < 95 and canFuel then
							if currentCash > 0 then
								DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.EToRefuel)

								if IsControlJustReleased(0, 38) then
									isFueling = true

									TriggerEvent('fuel:refuelFromPump', isNearPump, ped, vehicle)
									LoadAnimDict("timetable@gardener@filling_can")
								end
							else
								DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.NotEnoughCash)
							end
						elseif not canFuel then
							DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.JerryCanEmpty)
						else
							DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.FullTank)
						end
					end
				elseif isNearPump then
					local stringCoords = GetEntityCoords(isNearPump)

					if Config.UseESX then
						if currentCash >= Config.JerryCanCost then
							if not HasPedGotWeapon(ped, 883325847) then
								DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.PurchaseJerryCan)

								if IsControlJustReleased(0, 38) then
									GiveWeaponToPed(ped, 883325847, 4500, false, true)

									TriggerServerEvent('fuel:pay', Config.JerryCanCost)

									currentCash = ESX.GetPlayerData().money
								end
							else
								local refillCost = Round(Config.RefillCost * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))

								if refillCost > 0 then
									if currentCash >= refillCost then
										DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.RefillJerryCan .. refillCost)

										if IsControlJustReleased(0, 38) then
											TriggerServerEvent('fuel:pay', refillCost)

											SetPedAmmo(ped, 883325847, 4500)
										end
									else
										DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.NotEnoughCashJerryCan)
									end
								else
									DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.JerryCanFull)
								end
							end
						else
							DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.NotEnoughCash)
						end
					else
						if not HasPedGotWeapon(ped, 883325847) then
							DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.PurchaseJerryCan)

							if IsControlJustReleased(0, 38) then
								GiveWeaponToPed(ped, 883325847, 4500, false, true)
							end
						else
							if GetAmmoInPedWeapon(ped, 883325847) < 4500 then
								DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.RefillJerryCan)

								if IsControlJustReleased(0, 38) then
									SetPedAmmo(ped, 883325847, 4500)
								end
							else
								DrawText3Ds(stringCoords.x, stringCoords.y, stringCoords.z + 1.2, Config.Strings.JerryCanFull)
							end
						end
					end
				else
					Citizen.Wait(250)
				end
			end
		else
			Citizen.Wait(250)
		end

		Citizen.Wait(0)
	end
end)

if Config.ShowNearestGasStationOnly then
	Citizen.CreateThread(function()
		local currentGasBlip = 0

		while true do
			local coords = GetEntityCoords(PlayerPedId())
			local closest = 1000
			local closestCoords

			for _, gasStationCoords in pairs(Config.GasStations) do
				local dstcheck = #(coords - gasStationCoords)

				if dstcheck < closest then
					closest = dstcheck
					closestCoords = gasStationCoords
				end
			end

			if DoesBlipExist(currentGasBlip) then
				RemoveBlip(currentGasBlip)
			end

			currentGasBlip = CreateBlip(closestCoords)

			Citizen.Wait(10000)
		end
	end)
elseif Config.ShowAllGasStations then
	Citizen.CreateThread(function()
		for _, gasStationCoords in pairs(Config.GasStations) do
			CreateBlip(gasStationCoords)
		end
	end)
end

if Config.EnableHUD then
	local function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
		SetTextFont(font)
		SetTextProportional(0)
		SetTextScale(sc, sc)
		N_0x4e096588b13ffeca(jus)
		SetTextColour(r, g, b, a)
		SetTextDropShadow(0, 0, 0, 0,255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		AddTextComponentString(text)
		DrawText(x - 0.1+w, y - 0.02+h)
	end

	local mph = 0
	local kmh = 0
	local fuel = 0
	local displayHud = false
	local color = Config.ColorHUD
	local colorLowFuel = Config.ColorLowFuel

	Citizen.CreateThread(function()
		while true do
			colorLowFuel = Config.ColorLowFuel
			Citizen.Wait(500)
			colorLowFuel = Config.ColorHUD
			Citizen.Wait(500)
		end
	end)

	Citizen.CreateThread(function()
		while true do
			local ped = PlayerPedId()

			if IsPedInAnyVehicle(ped) and not (Config.RemoveHUDForBlacklistedVehicle and inBlacklisted) and not IsHudHidden() then
				local vehicle = GetVehiclePedIsIn(ped)
				local speed = GetEntitySpeed(vehicle)

				fuelNum = GetFuel(vehicle)
				mph = tostring(math.ceil(speed * 2.236936))
				kmh = tostring(math.ceil(speed * 3.6))
				fuel = tostring(math.ceil(fuelNum))

				if fuelNum >= Config.LowFuelLevel then
					color = Config.ColorHUD
				else
					color = colorLowFuel
				end

				displayHud = true
			else
				displayHud = false

				Citizen.Wait(500)
			end

			Citizen.Wait(50)
		end
	end)

	Citizen.CreateThread(function()
		while true do
			if displayHud then
				
				if Config.EnableSpeedHUD then
					DrawAdvancedText(0.130 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, mph, Config.ColorHUD.r, Config.ColorHUD.g, Config.ColorHUD.b, Config.ColorHUD.a, 6, 1)
					DrawAdvancedText(0.174 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, kmh, Config.ColorHUD.r, Config.ColorHUD.g, Config.ColorHUD.b, Config.ColorHUD.a, 6, 1)
					DrawAdvancedText(0.148 - Config.HUDx, 0.7765 - Config.HUDy, 0.005, 0.0028, 0.4, "mp/h              km/h", Config.ColorHUD.r, Config.ColorHUD.g, Config.ColorHUD.b, Config.ColorHUD.a, 6, 1)
				end
				
				-- New experimental fuel bar
				if Config.EnableBar then
					local topLeftX, topLeftY, topRightX, topRightY = table.unpack(getMinimapTop())
					
					if IsRadarHidden() then
						topLeftX, topLeftY, topRightX, topRightY = topLeftX+0.005, 0.955, topRightX-0.005, 0.955
					else
						topLeftX, topLeftY, topRightX, topRightY = topLeftX+0.005, topLeftY-0.005, topRightX-0.005, topRightY-0.005
					end
					
					local fuel = GetFuel(GetVehiclePedIsIn(PlayerPedId()))
					
					local width = topRightX - topLeftX
					local centerX = topLeftX + (width / 2)
					local centerY = topLeftY + 0.008
					local fill = width * (fuel / 100)
					local centerFill = topLeftX + (fill / 2)
					
					-- Draw background shadow
					DrawRect(centerX,centerY, width,0.016, 0,0,0, 100)
					
					local colors
					if fuel < Config.LowFuelLevel then
						if not tweening then
							Citizen.CreateThread(function()
								tween(tweenObj)
								tweening = true
							end)
						end
						
						colors = {
							r = lerp(Config.ColorBarLow1.r, Config.ColorBarLow2.r, tweenObj.v),
							g = lerp(Config.ColorBarLow1.g, Config.ColorBarLow2.g, tweenObj.v),
							b = lerp(Config.ColorBarLow1.b, Config.ColorBarLow2.b, tweenObj.v),
						}
					else
						if tweening then
							tweenHandle:stop()
							tweening = false
						end
						colors = {r = Config.ColorBar.r, g = Config.ColorBar.g, b = Config.ColorBar.b}
					end
					
					-- Draw fuel bar
					DrawRect(centerFill,centerY, fill,0.008, colors.r,colors.g,colors.b, 150)
				else
					
					DrawAdvancedText(0.2195 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, fuel, color.r, color.g, color.b, color.a, 6, 1)
					DrawAdvancedText(0.2397 - Config.HUDx, 0.7766 - Config.HUDy, 0.005, 0.0028, 0.4, "Fuel", color.r, color.g, color.b, color.a, 6, 1)
				end
			else
				Citizen.Wait(750)
			end

			Citizen.Wait(0)
		end
	end)
end

Citizen.CreateThread(function()
	while true do

		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then

			local vehicle = GetVehiclePedIsIn(ped)
			if GetPedInVehicleSeat(vehicle, -1) == ped then

				if GetFuel(vehicle) == 0.0 and DecorExistOn(vehicle, Config.FuelDecor) and GetIsVehicleEngineRunning(vehicle) then
					SetVehicleEngineOn(vehicle, false, false, true)
				end
			end
		end
		Citizen.Wait(1000)
	end
end)
