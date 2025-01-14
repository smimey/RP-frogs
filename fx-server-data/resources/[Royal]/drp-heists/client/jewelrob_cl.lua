
hasrobbed = {}
hasrobbed[1] = true
hasrobbed[2] = true
hasrobbed[3] = true
hasrobbed[4] = true
hasrobbed[5] = true
hasrobbed[6] = true
hasrobbed[7] = true
hasrobbed[8] = true
hasrobbed[9] = true
hasrobbed[10] = true
hasrobbed[11] = true
hasrobbed[12] = true
hasrobbed[13] = true
hasrobbed[14] = true
hasrobbed[15] = true
hasrobbed[16] = true
hasrobbed[17] = true
hasrobbed[18] = true
hasrobbed[19] = true
hasrobbed[20] = true
local jewelryBanksTimes = 0

local weaponTypes = {
    ["2685387236"] = { "Unarmed", ["slot"] = 0 },
    ["3566412244"] = { "Melee", ["slot"] = 1 },
    ["-728555052"] = { "Melee", ["slot"] = 1 },
    ["416676503"] = { "Pistol", ["slot"] = 2 },
    ["3337201093"] = { "SMG", ["slot"] = 3 },
    ["970310034"] = { "AssaultRifle", ["slot"] = 4 },
    ["-957766203"] = { "AssaultRifle", ["slot"] = 4 },
    ["3539449195"] = { "DigiScanner", ["slot"] = 4 },
    ["4257178988"] = { "FireExtinguisher", ["slot"] = 0 },
    ["1159398588"] = { "MG", ["slot"] = 4 },
    ["3493187224"] = { "NightVision", ["slot"] = 0 },
    ["431593103"] = { "Parachute", ["slot"] = 0 },
    ["860033945"] = { "Shotgun", ["slot"] = 3 },
    ["3082541095"] = { "Sniper", ["slot"] = 3 },
    ["690389602"] = { "Stungun", ["slot"] = 1 },
    ["2725924767"] = { "Heavy", ["slot"] = 4 },
    ["1548507267"] = { "Thrown", ["slot"] = 0 },
    ["1595662460"] = { "PetrolCan", ["slot"] = 1 }
}

local locations = {
	[1] = {-626.5326,-238.3758,38.05},
	[2] = {-625.6032, -237.5273, 38.05},
	[3] = {-626.9178, -235.5166, 38.05},
	[4] = {-625.6701, -234.6061, 38.05},
	[5] = {-626.8935, -233.0814, 38.05},
	[6] = {-627.9514, -233.8582, 38.05},
	[7] = {-624.5250, -231.0555, 38.05},
	[8] = {-623.0003, -233.0833, 38.05},
	[9] = {-620.1098, -233.3672, 38.05},
	[10] = {-620.2979, -234.4196, 38.05},
	[11] = {-619.0646, -233.5629, 38.05},
	[12] = {-617.4846, -230.6598, 38.05},
	[13] = {-618.3619, -229.4285, 38.05},
	[14] = {-619.6064, -230.5518, 38.05},
	[15] = {-620.8951, -228.6519, 38.05},
	[16] = {-619.7905, -227.5623, 38.05},
	[17] = {-620.6110, -226.4467, 38.05},
	[18] = {-623.9951, -228.1755, 38.05},
	[19] = {-624.8832, -227.8645, 38.05},
	[20] = {-623.6746, -227.0025, 38.05},
}

function weaponTypeC()
	local w = GetSelectedPedWeapon(PlayerPedId())
	local wg = GetWeapontypeGroup(w)
	if weaponTypes[""..wg..""] then
		return weaponTypes[""..wg..""]["slot"]
	else
		return 0
	end
end
function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

RegisterNetEvent("drp-jewelry:getHit")
AddEventHandler("drp-jewelry:getHit", function(result)
    jewelryBanksTimes = result
end)

RegisterNetEvent("drp-jewelry:GetTimeCL")
AddEventHandler("drp-jewelry:GetTimeCL", function(result)
    jewelryTimesHit = result
end)

RegisterNetEvent("drp-jewelry:GetTime2CL")
AddEventHandler("drp-jewelry:GetTime2CL", function(result)
    jewelryTimesHit2 = result
end)

Citizen.CreateThread(function()
    while true do
        if jewelryBanksTimes < 1 then
            Citizen.Wait(600000)
            TriggerServerEvent('drp-jewelry:getHitSVSV', 3)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent("drp-jewelry:addPlease")
AddEventHandler("drp-jewelry:addPlease", function() 
	TriggerServerEvent("drp-doors:change-lock-state", 111, false)
	TriggerServerEvent("drp-doors:change-lock-state", 112, false)
	TriggerServerEvent("jewel:canhit")
	TriggerEvent('drp-dispatch:jewrob')
	TriggerEvent("inventory:removeItem", "orangelaptop", 1)
	TriggerEvent('drp-robberies:hackinganim', false)
	local plyPos = GetEntityCoords(PlayerPedId(), true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-90A",
		isImportant = true,
		priority = 1,
		dispatchMessage = "Vangelico Jewelry Robbery",
		recipientList = {
		  police = "police"
		},
		origin = {
			x = plyPos.x,
			y = plyPos.y,
			z = plyPos.z
		}
	})
end)

RegisterNetEvent("drp-jewelry:removePlease")
AddEventHandler("drp-jewelry:removePlease", function() 
	TriggerEvent('DoLongHudText', 'Failed, Does not look like you have the brains!', 2)
	TriggerEvent('drp-dispatch:jewrob')
	TriggerServerEvent('drp-jewelry:getHitSVSV', jewelryBanksTimes - 1)
	TriggerEvent('drp-robberies:hackinganim', false)
	local plyPos = GetEntityCoords(PlayerPedId(), true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-90A",
		isImportant = true,
		priority = 1,
		dispatchMessage = "Vangelico Jewelry Robbery",
		recipientList = {
		  police = "police"
		},
		origin = {
			x = plyPos.x,
			y = plyPos.y,
			z = plyPos.z
		}
	})
end)

RegisterCommand("jtest", function()
    TriggerEvent("jewel:startrobberybitch")
end)

RegisterNetEvent("jewel:startrobberybitch")
AddEventHandler("jewel:startrobberybitch", function() 
	TriggerServerEvent('drp-jewelry:getHitSV')
	TriggerServerEvent('drp-jewelry:getTimeSV')
	TriggerServerEvent('drp-jewelry:getTime2SV')
	Citizen.Wait(1000)
	local copcount = exports["isPed"]:isPed("countpolice")
	if copcount >= -1 then 
		if exports["drp-inventory"]:hasEnoughOfItem("lockpick",1,false) then
			--if jewelryTimesHit2 > jewelryTimesHit then 
				if jewelryBanksTimes >= 1 then
					TriggerEvent('drp-robberies:hackinganim', true)
					Citizen.Wait(7000)
					exports["drp-heists"]:StartHacking({
						action = "open",
						time = 6,
						amount = 4,
						correct = 8,
						bankName = 'jewelry'
					})
				else
					TriggerEvent('DoLongHudText', 'Tablet is overloaded!', 2)
					return
				end
		--	else
			--	TriggerServerEvent('drp-jewelry:TimePoggers')
			--end
	   	else
			TriggerEvent('DoLongHudText', 'You do not have the required item to continue!', 2)
		end
   else
	   TriggerEvent('DoLongHudText', 'There is not enough cops on duty!', 2)
   end
end)

RegisterNetEvent("jewel:robbed")
AddEventHandler("jewel:robbed", function(newSet) 
	hasrobbed = newSet
end)

local jewelKOS = true
RegisterNetEvent('JewelKOS')
AddEventHandler('JewelKOS', function()
	if jewelKOS then
		return
	end
	jewelKOS = true
    SetPedRelationshipGroupDefaultHash(PlayerPedId(),`MISSION3`)
    SetPedRelationshipGroupHash(PlayerPedId(),`MISSION3`)
    Wait(1800000)
    SetPedRelationshipGroupDefaultHash(PlayerPedId(),`PLAYER`)
    SetPedRelationshipGroupHash(PlayerPedId(),`PLAYER`)
    jewelKOS = false
end)

function giveitems()
	local random = math.random(150)
	if weaponTypeC() > 2 then

		if random < 10 then
			TriggerEvent("player:receiveItem", "truckkey", 1)
		end

		TriggerEvent("player:receiveItem", "rolexwatch",math.random(10,20))

		if math.random(5) == 1 then
			TriggerEvent("player:receiveItem", "goldbar",math.random(1,15))
		end

		if math.random(69) == 69 then
			TriggerEvent("player:receiveItem", "valuablegoods",math.random(15))
		end

		if math.random(99) == 99 then
			TriggerEvent("player:receiveItem", "aldente",math.random(1))
		end

		if math.random(100) == 100 then
			TriggerEvent("player:receiveItem", "likemotherlikedaughter",math.random(1))
		end

		if math.random(98) == 98 then
			TriggerEvent("player:receiveItem", "krishna",math.random(1))
		end

		if math.random(97) == 97 then
			TriggerEvent("player:receiveItem", "queenesther",math.random(1))
		end

		TriggerEvent("player:receiveItem", "goldbar",1)
	end
end


local warning = false
function AttackGlass(num)
	if math.random(100) > 70 or weaponTypeC() > 2 then
		Citizen.Wait(1500)
		ClearPedTasks(PlayerPedId())
		local plyPos = GetEntityCoords(PlayerPedId())
		if math.random(50) > 45 then
			TriggerEvent('drp-dispatch:jewrob')
			TriggerServerEvent("dispatch:svNotify", {
				dispatchCode = "10-90A",
				isImportant = true,
				priority = 1,
				dispatchMessage = "Vangelico Jewelry Robbery",
				recipientList = {
				  police = "police"
				},
				origin = {
					x = plyPos.x,
					y = plyPos.y,
					z = plyPos.z
				}
			})
		end
		TriggerServerEvent("jewel:hasrobbed",num)
		TriggerEvent("customNotification","You broke the glass and got some items!",2)
		giveitems()
		hasrobbed[num] = true
	else
		TriggerEvent("customNotification","You failed to break the glass - more force would help.",2)
		ClearPedTasks(PlayerPedId())
	end	
end

RegisterNetEvent('event:control:jewelRob')
AddEventHandler('event:control:jewelRob', function(useID)
	if not IsPedRunning(PlayerPedId()) and not IsPedSprinting(PlayerPedId()) and not hasrobbed[useID] then
		local v = locations[useID]
		local player = GetPlayerPed( -1 )
		TaskTurnPedToFaceCoord(player,v[1],v[2],v[3],1.0)
		Citizen.Wait(500)
		loadParticle()
		StartParticleFxLoopedAtCoord("scr_jewel_cab_smash",v[1],v[2],v[3], 0.0, 0.0, 0.0, 1.0, false, false, false, false)
		loadAnimation()
		AttackGlass(useID)
		warning = false
	end
end)

Citizen.CreateThread(function()
	while true do
		if (#(GetEntityCoords(PlayerPedId()) - vector3(-626.5326, -238.3758, 38.05)) < 100.0) then

			for i=1,#locations do
				local v = locations[i]
				if (#(GetEntityCoords(PlayerPedId()) - vector3(v[1],v[2],v[3])) < 0.9 ) then
					if (not hasrobbed[i]) then
						DrawText3Ds(v[1],v[2],v[3])
						if IsControlJustReleased(0,38) and not warning then
							TriggerEvent('event:control:jewelRob', i)
							warning = true
						end
					end
				end
			end
			Citizen.Wait(0)
		else
			Citizen.Wait(2000)
		end
	end
end)

function loadParticle()
	if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
    RequestNamedPtfxAsset("scr_jewelheist")
    end
    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
    Citizen.Wait(0)
    end
    SetPtfxAssetNextCall("scr_jewelheist")
end

function loadAnimation()
	loadAnimDict( "missheist_jewel" ) 
	TriggerEvent('InteractSound_CL:PlayOnOne', 'robberyglassbreak', 1.0)
	TaskPlayAnim( PlayerPedId(), "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0 ) 
	Citizen.Wait(2200)
end

function DT(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DrawText3Ds(x,y,z)
	local text = "Press [E] to rob!"
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent("drp-jewelry:outcome")
AddEventHandler("drp-jewelry:outcome", function(arg)
	TriggerEvent('DoLongHudText', arg, 2)
end)