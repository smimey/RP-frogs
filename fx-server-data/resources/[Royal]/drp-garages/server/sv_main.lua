RPC.register("drp-garages:selectMenu", function(pGarage, pJob)
	local pSrc = source
	if pGarage == 'garagepd' or pGarage == 'garagefib' or pGarage == 'garagepdpaleto' then
		if pJob == 'police' or pJob == 'state' or pJob == 'sheriff' then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Shared Vehicles",
					txt = "List of all the shared vehicles.",
					params = {
						event = "drp-garages:openSharedGarage"
					}
				},
				{
					id = 2,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		end
	
	elseif pGarage == 'garageems' then
		if pJob == 'ems' then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Shared Vehicles",
					txt = "List of all the shared vehicles.",
					params = {
						event = "drp-garages:openSharedGarage"
					}
				},
				{
					id = 2,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		end

	elseif pGarage == 'garage_mrpdheli' then
		if pJob == 'police' or pJob == 'state' or pJob == 'sheriff' then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Shared Vehicles",
					txt = "List of all the shared vehicles.",
					params = {
						event = "drp-garages:openSharedGarage"
					}
				},
				{
					id = 2,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "Personal Vehicles",
					txt = "List of all the personal vehicles.",
					params = {
						event = "drp-garages:openPersonalGarage"
					}
				},
			})
		end
	else
		TriggerClientEvent('drp-context:sendMenu', pSrc, {
			{
				id = 1,
				header = "Personal Vehicles",
				txt = "List of all the personal vehicles.",
				params = {
					event = "drp-garages:openPersonalGarage"
				}
			},
		})
	end
	
end)

RPC.register("drp-garages:select", function(pGarage)
    local pSrc = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(pSrc)
    local char = user:getCurrentCharacter()
	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE cid = @cid AND current_garage = @garage', { ['@cid'] = char.id, ['@garage'] = pGarage}, function(vehicles)
        if vehicles[1] ~= nil then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "<--- Back",
					txt = "",
					params = {
						event = "drp-garages:selectMenu",
					}
				},
			})
            for i = 1, #vehicles do
				if vehicles[i].vehicle_state ~= "Out" then
					TriggerClientEvent('drp-context:sendMenu', pSrc, {
						{
							id = vehicles[i].id,
							header = vehicles[i].model,
							txt = "Plate: "..vehicles[i].license_plate,
							params = {
								event = "drp-garages:attempt:spawn",
								args = {
									id = vehicles[i].id,
									engine_damage = vehicles[i].engine_damage,
									current_garage = vehicles[i].current_garage,
									body_damage = vehicles[i].body_damage,
									model = vehicles[i].model,
									fuel = vehicles[i].fuel, 
									customized = vehicles[i].data,
									plate = vehicles[i].license_plate,
									enigine_damage = vehicles[i].engine_damage,
									body_damage = vehicles[i].body_damage,
								}
							}
						},
					})
					pPassed = json.encode(vehicles)
				end
            end
        else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "No Vehicles",
					txt = "All vehicles are out!"
				},
			})
            return
        end
	end)
end)


RPC.register("drp-garages:selectSharedGarage", function(pGarage, pJob)
    local pSrc = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(pSrc)
    local char = user:getCurrentCharacter()
	if pJob == 'police' or pJob == 'state' or pJob == 'sheriff' then
		pType = 'law'
	elseif pJob == 'ems' then
		pType = 'medical'
	end	

	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE garage_info = @garage_info AND current_garage = @garage', { ['@garage_info'] = pType, ['@garage'] = pGarage}, function(vehicles)
        if vehicles[1] ~= nil then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "<--- Back",
					txt = "",
					params = {
						event = "drp-garages:selectMenu",
					}
				},
			})
            for i = 1, #vehicles do
				if vehicles[i].vehicle_state ~= "Out" then
					if pGarage ~= "garagepd" and pGarage ~= 'garagefib' and pGarage ~= 'garagepdpaleto'  then
						TriggerClientEvent('drp-context:sendMenu', pSrc, {
							{
								id = vehicles[i].id,
								header = vehicles[i].name,
								txt = "Plate: "..vehicles[i].license_plate,
								params = {
									event = "drp-garages:attempt:spawn",
									args = {
										id = vehicles[i].id,
										engine_damage = vehicles[i].engine_damage,
										current_garage = vehicles[i].current_garage,
										body_damage = vehicles[i].body_damage,
										model = vehicles[i].model,
										fuel = vehicles[i].fuel, 
										customized = vehicles[i].data,
										plate = vehicles[i].license_plate,
										enigine_damage = vehicles[i].engine_damage,
										body_damage = vehicles[i].body_damage,
									}
								}
							},
						})
					end
				end
            end

			if pType == "law" and (pGarage == "garagepd" or pGarage == 'garagefib' or pGarage == 'garagepdpaleto')  then
				TriggerClientEvent('drp-context:sendMenu', pSrc, {
					{
						id = 1,
						header = "Normal",
						txt = "Check the normal vehicles",
						params = {
							event = "drp-garages:open:law:normal",
						}
					},
					{
						id = 2,
						header = "Interceptor",
						txt = "Check the Interceptor vehicles",
						params = {
							event = "drp-garages:open:law:interceptor",
						}
					},
					{
						id = 3,
						header = "Undercover",
						txt = "Check the Undercover vehicles",
						params = {
							event = "drp-garages:open:law:uc",
						}
					},
					{
						id = 4,
						header = "Others",
						txt = "Check the other vehicles",
						params = {
							event = "drp-garages:open:law:others",
						}
					}
				})
			end
		else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "No Vehicles",
					txt = "All vehicles are out!"
				},
			})
            return
        end
	end)
end)

function table.contains(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
  end

RPC.register("drp-garages:open:law", function(pGarage, pJob, type)
	local pSrc = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(pSrc)
    local char = user:getCurrentCharacter()
	if pJob == 'police' or pJob == 'state' or pJob == 'sheriff' then
		pType = 'law'
	end 

	local carModels = {}

	if type == "normal" then
		carModels = {
			"npolvic",
			"npolexp",
			"prangerold",
		}
	elseif type == "interceptor" then
		carModels = {
			"npolvette",
			"npolstang",
			"npolchal",
			"npolchar"
		}
	elseif type == "uc" then
		carModels = {
			"ucwashington",
			"ucrancher",
			"ucprimo",
			"ucballer",
			"ucbuffalo",
			"uccoquette",
			"ucbanshee",
			"uccomet",
		}
		
	elseif type == "others" then
		carModels = {
			"ucwashington",
			"ucrancher",
			"ucprimo",
			"ucballer",
			"ucbuffalo",
			"uccoquette",
			"ucbanshee",
			"uccomet",
			"npolvette",
			"npolstang",
			"npolchal",
			"npolchar",
			"npolvic",
			"npolexp",
			"prangerold",
		}
	end

	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE garage_info = @garage_info AND current_garage = @garage', { ['@garage_info'] = pType, ['@garage'] = pGarage}, function(vehicles)
		if vehicles[1] ~= nil then
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "<--- Back",
					txt = "",
					params = {
						event = "drp-garages:openSharedGarage",
					}
				},
			})
			for i = 1, #vehicles do
				if vehicles[i].vehicle_state ~= "Out" then
					-- check if vehicles[i].model is in carModels
					if type ~= "others" then
						if table.contains(carModels, vehicles[i].model) then
							TriggerClientEvent('drp-context:sendMenu', pSrc, {
								{
									id = vehicles[i].id,
									header = vehicles[i].name,
									txt = "Plate: "..vehicles[i].license_plate,
									params = {
										event = "drp-garages:attempt:spawn",
										args = {
											id = vehicles[i].id,
											engine_damage = vehicles[i].engine_damage,
											current_garage = vehicles[i].current_garage,
											body_damage = vehicles[i].body_damage,
											model = vehicles[i].model,
											fuel = vehicles[i].fuel, 
											customized = vehicles[i].data,
											plate = vehicles[i].license_plate,
											enigine_damage = vehicles[i].engine_damage,
											body_damage = vehicles[i].body_damage,
										}
									}
								},
							})
						end
					else 
						if not table.contains(carModels, vehicles[i].model) then
							TriggerClientEvent('drp-context:sendMenu', pSrc, {
								{
									id = vehicles[i].id,
									header = vehicles[i].name,
									txt = "Plate: "..vehicles[i].license_plate,
									params = {
										event = "drp-garages:attempt:spawn",
										args = {
											id = vehicles[i].id,
											engine_damage = vehicles[i].engine_damage,
											current_garage = vehicles[i].current_garage,
											body_damage = vehicles[i].body_damage,
											model = vehicles[i].model,
											fuel = vehicles[i].fuel, 
											customized = vehicles[i].data,
											plate = vehicles[i].license_plate,
											enigine_damage = vehicles[i].engine_damage,
											body_damage = vehicles[i].body_damage,
										}
									}
								},
							})
						end
					end
				end
			end 
		else
			TriggerClientEvent('drp-context:sendMenu', pSrc, {
				{
					id = 1,
					header = "No Vehicles",
					txt = "All vehicles are out!"
				},
			})
			return
		end
	end)
end)

RPC.register("drp-garages:attempt:sv", function(data)
    local pSrc = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(pSrc)
    local char = user:getCurrentCharacter()


    local enginePercent = data.engine_damage / 10
	local bodyPercent = data.body_damage / 10
	TriggerClientEvent('drp-context:sendMenu', pSrc, {
		{
			id = 1,
			header = "< Go Back",
			txt = "Return to your list of all your vehicles.",
			params = {
				event = "drp-garages:open"
			}
		},
		{
			id = 2,
			header = "Take Out Vehicle",
			txt = "Spawn the vehicle!",
			params = {
				event = "drp-garages:takeout",
				args = {
					pVeh = data.id
				}
			}
			
		},
		{
			id = 3,
			header = "Vehicle Status",
			txt = "Garage: "..data.current_garage.." | Engine: "..enginePercent.."% | Body: "..bodyPercent.."%"
		},
	})
end)

RPC.register("drp-garages:spawned:get", function(pID)
	
    local pSrc = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(pSrc)
    local char = user:getCurrentCharacter()
	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE id = @id', {['@id'] = pID}, function(vehicles)
		args = {
			model = vehicles[1].model,
			fuel = vehicles[1].fuel, 
			customized = vehicles[1].data,
			plate = vehicles[1].license_plate,
			engine_damage = vehicles[1].engine_damage,
			body_damage = vehicles[1].body_damage,
		}
	
		if vehicles[1].current_garage == "Impound Lot" and vehicles[1].vehicle_state == 'Normal Impound' then
			if user:getCash() >= 100 then
				user:removeMoney(100)
				TriggerClientEvent("drp-garages:attempt:spawn", pSrc, args, true)
			else
				TriggerClientEvent('DoLongHudText', pSrc, "You need $100", 2)
				return
			end
		else
			if vehicles[1].finance_time == 0 then 
			--	TriggerClientEvent('DoLongHudText', pSrc, "You must make a car payment to use valet.", 2)
				
				Citizen.Wait(100)
			--	TriggerClientEvent('drp-garages:store')
				return
			else 
			TriggerClientEvent("drp-garages:attempt:spawn", pSrc, args, true)
			end
		end
	
	end)
end)

RPC.register("drp-garages:states", function(pState, plate, garage, fuel, engine_damage, body_damage)
    local pSrc = source
	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE license_plate = ?', {plate}, function(pIsValid)
		if pIsValid[1] then
			pExist = true
			 
			-- round engine and body damage
			engine_damage = math.floor(engine_damage or 1000)
			body_damage = math.floor(body_damage or 1000)

			Citizen.Trace(engine_damage .. " " .. body_damage .. "\n")

			exports.ghmattimysql:execute("UPDATE characters_cars SET current_garage = @garage, fuel = @fuel, engine_damage = @engine_damage, body_damage = @body_damage, vehicle_state = @state, coords = @coords WHERE license_plate = @plate", {
				['@garage'] = garage,
				['@fuel'] = fuel,
				['@engine_damage'] = engine_damage,
				['@body_damage'] = body_damage,
				['@state'] = pState,
				['@coords'] = json.encode({x = 0, y = 0, z = 0}),
				['@plate'] = plate
			})
		else
			pExist = false
		end
	end)

	Citizen.Wait(100)
	return pExist
end)

RegisterServerEvent('updateVehicle')
AddEventHandler('updateVehicle', function(vehicleMods,plate)
	vehicleMods = json.encode(vehicleMods)
	exports.ghmattimysql:execute("UPDATE characters_cars SET data=@mods WHERE license_plate = @plate",{['mods'] = vehicleMods, ['plate'] = plate})
end)


RegisterNetEvent("garages:loaded:in", function()
    local src = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(src)
    local char = user:getCurrentCharacter()
    local owner = char.id

    exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE cid = @cid', { ['@cid'] = owner}, function(vehicles)
		TriggerClientEvent('phone:Garage', src, vehicles)
    end)
end)

function ResetGaragesServer()
	exports.ghmattimysql:execute('SELECT * FROM characters_cars WHERE repoed = ?', {"0"}, function(vehicles)
		for k, v in ipairs(vehicles) do
			if v.vehicle_state == "Out" then
				exports.ghmattimysql:execute("UPDATE characters_cars SET vehicle_state = @state, coords = @coords WHERE license_plate = @plate", {['state'] = 'In', ['coords'] = nil, ['plate'] = v.license_plate})
			end
		end
	end)
end

Citizen.CreateThread(function()
    ResetGaragesServer();
end)