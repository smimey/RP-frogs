local enabled = false
local player = false
local firstChar = false
local cam = false
local customCam = false
local oldPed = false
local startingMenu = false

local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local prop_names = {"hats", "glasses", "earrings", "mouth", "lhand", "rhand", "watches", "braclets"}
local head_overlays = {"Blemishes","FacialHair","Eyebrows","Ageing","Makeup","Blush","Complexion","SunDamage","Lipstick","MolesFreckles","ChestHair","BodyBlemishes","AddBodyBlemishes"}
local face_features = {"Nose_Width","Nose_Peak_Hight","Nose_Peak_Lenght","Nose_Bone_High","Nose_Peak_Lowering","Nose_Bone_Twist","EyeBrown_High","EyeBrown_Forward","Cheeks_Bone_High","Cheeks_Bone_Width","Cheeks_Width","Eyes_Openning","Lips_Thickness","Jaw_Bone_Width","Jaw_Bone_Back_Lenght","Chimp_Bone_Lowering","Chimp_Bone_Lenght","Chimp_Bone_Width","Chimp_Hole","Neck_Thikness"}
local tatCategory = GetTatCategs()
local tattooHashList = CreateHashList()

local isService = false
local passedClothing = true

local currentPrice = 0

local MenuData = {
    clothing_shop = {
        text = "To buy clothes",
        displayName = "Clothing Store",
        basePrice = 200
    },
    barber_shop = {
        text = "Barber's",
        displayName = "Barber Shop",
        basePrice = 200
    },
    tattoo_shop = {
        text = "Tatooist",
        displayName = "Tattoo Parlor",
        basePrice = 200
    }
}

local listening = false

function RefreshUI()
    hairColors = {}
    for i = 0, GetNumHairColors()-1 do
        local outR, outG, outB= GetPedHairRgbColor(i)
        hairColors[i] = {outR, outG, outB}
    end

    makeupColors = {}
    for i = 0, GetNumMakeupColors()-1 do
        local outR, outG, outB= GetPedMakeupRgbColor(i)
        makeupColors[i] = {outR, outG, outB}
    end

    SendNUIMessage({
        type="colors",
        hairColors=hairColors,
        makeupColors=makeupColors,
        hairColor=GetPedHair()
    })
    SendNUIMessage({
        type = "menutotals",
        drawTotal = GetDrawablesTotal(),
        propDrawTotal = GetPropDrawablesTotal(),
        textureTotal = GetTextureTotals(),
        headoverlayTotal = GetHeadOverlayTotals(),
        skinTotal = GetSkinTotal()
    })
    SendNUIMessage({
        type = "barber_shop",
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructureData()
    })
    SendNUIMessage({
        type = "clothing_shopdata",
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
        skin = GetSkin(),
        oldPed = oldPed,
    })
    SendNUIMessage({
        type = "tattoo_shop",
        totals = tatCategory,
        values = GetTats()
    })
end

function GetSkin()
    for i = 1, #frm_skins do
        if (GetHashKey(frm_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_male", value=i}
        end
    end
    for i = 1, #fr_skins do
        if (GetHashKey(fr_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_female", value=i}
        end
    end
    return false
end

function GetDrawables()
    drawables = {}
    local model = GetEntityModel(PlayerPedId())
    local mpPed = false
    if (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
        mpPed = true
    end
    for i = 0, #drawable_names-1 do
        if mpPed and drawable_names[i+1] == "undershirts" and GetPedDrawableVariation(player, i) == -1 then
            SetPedComponentVariation(player, i, 15, 0, 2)
        end
        drawables[i] = {drawable_names[i+1], GetPedDrawableVariation(player, i)}
    end
    return drawables
end

function GetProps()
    props = {}
    for i = 0, #prop_names-1 do
        props[i] = {prop_names[i+1], GetPedPropIndex(player, i)}
    end
    return props
end

function GetDrawTextures()
    textures = {}
    for i = 0, #drawable_names-1 do
        table.insert(textures, {drawable_names[i+1], GetPedTextureVariation(player, i)})
    end
    return textures
end

function GetPropTextures()
    textures = {}
    for i = 0, #prop_names-1 do
        table.insert(textures, {prop_names[i+1], GetPedPropTextureIndex(player, i)})
    end
    return textures
end

function GetDrawablesTotal()
    drawables = {}
    for i = 0, #drawable_names - 1 do
        drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(player, i)}
    end
    return drawables
end

function GetPropDrawablesTotal()
    props = {}
    for i = 0, #prop_names - 1 do
        props[i] = {prop_names[i+1], GetNumberOfPedPropDrawableVariations(player, i)}
    end
    return props
end

function GetTextureTotals()
    local values = {}
    local draw = GetDrawables()
    local props = GetProps()

    for idx = 0, #draw-1 do
        local name = draw[idx][1]
        local value = draw[idx][2]
        values[name] = GetNumberOfPedTextureVariations(player, idx, value)
    end

    for idx = 0, #props-1 do
        local name = props[idx][1]
        local value = props[idx][2]
        values[name] = GetNumberOfPedPropTextureVariations(player, idx, value)
    end
    return values
end

function SetClothing(drawables, props, drawTextures, propTextures)
    for i = 1, #drawable_names do
        if drawables[0] == nil then
            if drawable_names[i] == "undershirts" and drawables[tostring(i-1)][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[tostring(i-1)][2], drawTextures[i][2], 2)
            end
        else
            if drawable_names[i] == "undershirts" and drawables[i-1][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[i-1][2], drawTextures[i][2], 2)
            end
        end
    end

    for i = 1, #prop_names do
        local propZ = (drawables[0] == nil and props[tostring(i-1)][2] or props[i-1][2])
        ClearPedProp(player, i-1)
        SetPedPropIndex(
            player,
            i-1,
            propZ,
            propTextures[i][2], true)
    end
end

function GetSkinTotal()
  return {
    #frm_skins,
    #fr_skins
  }
end

local toggleClothing = {}
function ToggleProps(data)
    local name = data["name"]

    selectedValue = has_value(drawable_names, name)
    if (selectedValue > -1) then
        if (toggleClothing[name] ~= nil) then
            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            toggleClothing[name] = {
                GetPedDrawableVariation(player, tonumber(selectedValue)),
                GetPedTextureVariation(player, tonumber(selectedValue))
            }

            local value = -1
            if name == "undershirts" or name == "torsos" then
                value = 15
                if name == "undershirts" and GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
                    value = -1
                end
            end
            if name == "legs" then
                value = 14
            end

            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                value, 0, 2)
        end
    else
        selectedValue = has_value(prop_names, name)
        if (selectedValue > -1) then
            if (toggleClothing[name] ~= nil) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            else
                toggleClothing[name] = {
                    GetPedPropIndex(player, tonumber(selectedValue)),
                    GetPedPropTextureIndex(player, tonumber(selectedValue))
                }
                ClearPedProp(player, tonumber(selectedValue))
            end
        end
    end
end

function SaveToggleProps()
    for k in pairs(toggleClothing) do
        local name  = k
        selectedValue = has_value(drawable_names, name)
        if (selectedValue > -1) then
            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            selectedValue = has_value(prop_names, name)
            if (selectedValue > -1) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            end
        end
    end
end

function LoadPed(data)
    SetSkin(data.model, true)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
    SetPedHairColor(player, tonumber(data.hairColor[1]), tonumber(data.hairColor[2]))
    SetPedHeadBlend(data.headBlend)
    SetHeadStructure(data.headStructure)
    SetHeadOverlayData(data.headOverlay)
    return
end

function GetCurrentPed()
    player = PlayerPedId()
    return {
        model = GetEntityModel(PlayerPedId()),
        hairColor = GetPedHair(),
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructure(),
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
    }
end

function PlayerModel(data)
    local skins = nil
    if (data['name'] == 'skin_male') then
        skins = frm_skins
    else
        skins = fr_skins
    end
    local skin = skins[tonumber(data['value'])]
    rotation(180.0)
    SetSkin(GetHashKey(skin), true)
    Citizen.Wait(1)
    rotation(180.0)
end

local function ToggleClothingToLoadPed()
    local ped = PlayerPedId()
    local drawables = GetDrawablesTotal()

    for num, _ in pairs(drawables) do
        if drawables[num][2] > 1 then
            component = tonumber(num)
            SetPedComponentVariation(ped, component, 1, 0, 0)
            Wait(250)
            SetPedComponentVariation(ped, component, 0, 0, 0)
            break
        end
    end
end

local inSpawn = false
AddEventHandler("raid_clothes:inSpawn", function(pInSpawn)
    inSpawn = pInSpawn
end)

function SetSkin(model, setDefault)
    -- TODO: If not isCop and model not in copModellist, do below.
    -- Model is a hash, GetHashKey(modelName)
    SetEntityInvincible(PlayerPedId(),true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while (not HasModelLoaded(model)) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        player = PlayerPedId()
        FreezePedCameraRotation(player, true)
        SetPedMaxHealth(player, 200)
        ToggleClothingToLoadPed()
        SetPedDefaultComponentVariation(player)
        if inSpawn then
            SetEntityHealth(player, GetEntityMaxHealth(player))
        end
        if setDefault and model ~= nil and not isCustomSkin(model) and (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
            SetPedHeadBlendData(player, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
            SetPedComponentVariation(player, 11, 0, 1, 0)
            SetPedComponentVariation(player, 8, 0, 1, 0)
            SetPedComponentVariation(player, 6, 1, 2, 0)
            SetPedHeadOverlayColor(player, 1, 1, 0, 0)
            SetPedHeadOverlayColor(player, 2, 1, 0, 0)
            SetPedHeadOverlayColor(player, 4, 2, 0, 0)
            SetPedHeadOverlayColor(player, 5, 2, 0, 0)
            SetPedHeadOverlayColor(player, 8, 2, 0, 0)
            SetPedHeadOverlayColor(player, 10, 1, 0, 0)
            SetPedHeadOverlay(player, 1, 0, 0.0)
            SetPedHairColor(player, 1, 1)
        end
    end
    SetEntityInvincible(PlayerPedId(),false)
    TriggerEvent("Animation:Set:Reset")
end

RegisterNUICallback('updateclothes', function(data, cb)
    toggleClothing[data["name"]] = nil
    selectedValue = has_value(drawable_names, data["name"])
    if (selectedValue > -1) then
        if data["name"] == "face" and tonumber(data["value"]) == -1 then
            return
        end
        SetPedComponentVariation(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), 2)
        cb({
            GetNumberOfPedTextureVariations(player, tonumber(selectedValue), tonumber(data["value"]))
        })
    else
        selectedValue = has_value(prop_names, data["name"])
        if (tonumber(data["value"]) == -1) then
            ClearPedProp(player, tonumber(selectedValue))
        else
            SetPedPropIndex(
                player,
                tonumber(selectedValue),
                tonumber(data["value"]),
                tonumber(data["texture"]), true)
        end
        cb({
            GetNumberOfPedPropTextureVariations(
                player,
                tonumber(selectedValue),
                tonumber(data["value"])
            )
        })
    end
end)

RegisterNUICallback('customskin', function(data, cb)
    if canUseCustomSkins() then
        local valid_model = isInSkins(data)
        if valid_model then
            SetSkin(GetHashKey(data), true)
        end
    end
end)

RegisterNUICallback('setped', function(data, cb)
    PlayerModel(data)
    RefreshUI()
    cb('ok')
end)

RegisterNUICallback('resetped', function(data, cb)
    LoadPed(oldPed)
    cb('ok')
end)


------------------------------------------------------------------------------------------
-- Barber

function GetPedHeadBlendData()
    local blob = string.rep("\0\0\0\0\0\0\0\0", 6 + 3 + 1) -- Generate sufficient struct memory.
    if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, player, blob, true) then -- Attempt to write into memory blob.
        return nil
    end

    return {
        shapeFirst = string.unpack("<i4", blob, 1),
        shapeSecond = string.unpack("<i4", blob, 9),
        shapeThird = string.unpack("<i4", blob, 17),
        skinFirst = string.unpack("<i4", blob, 25),
        skinSecond = string.unpack("<i4", blob, 33),
        skinThird = string.unpack("<i4", blob, 41),
        shapeMix = string.unpack("<f", blob, 49),
        skinMix = string.unpack("<f", blob, 57),
        thirdMix = string.unpack("<f", blob, 65),
        hasParent = string.unpack("b", blob, 73) ~= 0,
    }
end

function SetPedHeadBlend(data)
    if data ~= nil then
        SetPedHeadBlendData(player,
            tonumber(data['shapeFirst']),
            tonumber(data['shapeSecond']),
            tonumber(data['shapeThird']),
            tonumber(data['skinFirst']),
            tonumber(data['skinSecond']),
            tonumber(data['skinThird']),
            tonumber(data['shapeMix']),
            tonumber(data['skinMix']),
            tonumber(data['thirdMix']),
            false)
    end
end

function GetHeadOverlayData()
    local headData = {}
    for i = 1, #head_overlays do
        local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, i-1)
        if retval then
            headData[i] = {}
            headData[i].name = head_overlays[i]
            headData[i].overlayValue = overlayValue
            headData[i].colourType = colourType
            headData[i].firstColour = firstColour
            headData[i].secondColour = secondColour
            headData[i].overlayOpacity = overlayOpacity
        end
    end
    return headData
end

function SetHeadOverlayData(data)
    if json.encode(data) ~= "[]" then
        for i = 1, #head_overlays do
            SetPedHeadOverlay(player,  i-1, tonumber(data[i].overlayValue),  tonumber(data[i].overlayOpacity))
            -- SetPedHeadOverlayColor(player, i-1, data[i].colourType, data[i].firstColour, data[i].secondColour)
        end

        SetPedHeadOverlayColor(player, 0, 0, tonumber(data[1].firstColour), tonumber(data[1].secondColour))
        SetPedHeadOverlayColor(player, 1, 1, tonumber(data[2].firstColour), tonumber(data[2].secondColour))
        SetPedHeadOverlayColor(player, 2, 1, tonumber(data[3].firstColour), tonumber(data[3].secondColour))
        SetPedHeadOverlayColor(player, 3, 0, tonumber(data[4].firstColour), tonumber(data[4].secondColour))
        SetPedHeadOverlayColor(player, 4, 2, tonumber(data[5].firstColour), tonumber(data[5].secondColour))
        SetPedHeadOverlayColor(player, 5, 2, tonumber(data[6].firstColour), tonumber(data[6].secondColour))
        SetPedHeadOverlayColor(player, 6, 0, tonumber(data[7].firstColour), tonumber(data[7].secondColour))
        SetPedHeadOverlayColor(player, 7, 0, tonumber(data[8].firstColour), tonumber(data[8].secondColour))
        SetPedHeadOverlayColor(player, 8, 2, tonumber(data[9].firstColour), tonumber(data[9].secondColour))
        SetPedHeadOverlayColor(player, 9, 0, tonumber(data[10].firstColour), tonumber(data[10].secondColour))
        SetPedHeadOverlayColor(player, 10, 1, tonumber(data[11].firstColour), tonumber(data[11].secondColour))
        SetPedHeadOverlayColor(player, 11, 0, tonumber(data[12].firstColour), tonumber(data[12].secondColour))
    end
end

function GetHeadOverlayTotals()
    local totals = {}
    for i = 1, #head_overlays do
        totals[head_overlays[i]] = GetNumHeadOverlayValues(i-1)
    end
    return totals
end

function GetPedHair()
    local hairColor = {}
    hairColor[1] = GetPedHairColor(player)
    hairColor[2] = GetPedHairHighlightColor(player)
    return hairColor
end

function GetHeadStructureData()
    local structure = {}
    for i = 1, #face_features do
        structure[face_features[i]] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function GetHeadStructure(data)
    local structure = {}
    for i = 1, #face_features do
        structure[i] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function SetHeadStructure(data)
    for i = 1, #face_features do
        SetPedFaceFeature(player, i-1, data[i])
    end
end


RegisterNUICallback('saveheadblend', function(data, cb)
    SetPedHeadBlendData(player,
    tonumber(data.shapeFirst),
    tonumber(data.shapeSecond),
    tonumber(data.shapeThird),
    tonumber(data.skinFirst),
    tonumber(data.skinSecond),
    tonumber(data.skinThird),
    tonumber(data.shapeMix) / 100,
    tonumber(data.skinMix) / 100,
    tonumber(data.thirdMix) / 100, false)
    cb('ok')
end)

RegisterNUICallback('savehaircolor', function(data, cb)
    SetPedHairColor(player, tonumber(data['firstColour']), tonumber(data['secondColour']))
end)

RegisterNUICallback('savefacefeatures', function(data, cb)
    local index = has_value(face_features, data["name"])
    if (index <= -1) then return end
    local scale = tonumber(data["scale"]) / 100
    SetPedFaceFeature(player, index, scale)
    cb('ok')
end)

RegisterNUICallback('saveheadoverlay', function(data, cb)
    local index = has_value(head_overlays, data["name"])
    SetPedHeadOverlay(player,  index, tonumber(data["value"]), tonumber(data["opacity"]) / 100)
    cb('ok')
end)

RegisterNUICallback('saveheadoverlaycolor', function(data, cb)
    local index = has_value(head_overlays, data["name"])
    local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, index)
    local sColor = tonumber(data['secondColour'])
    if (sColor == nil) then
        sColor = tonumber(data['firstColour'])
    end
    SetPedHeadOverlayColor(player, index, colourType, tonumber(data['firstColour']), sColor)
    cb('ok')
end)


----------------------------------------------------------------------------------
-- UTIL SHIT


function has_value (tab, val)
    for index = 1, #tab do
        if tab[index] == val then
            return index-1
        end
    end
    return -1
end

function EnableGUI(enable, menu, pPriceText, pPrice,disableDestroyCams)
    enabled = enable
    SetCustomNuiFocus(enable, enable)
    SendNUIMessage({
        type = "enableclothing_shop",
        enable = enable,
        menu = menu,
        priceText = pPriceText,
        price = pPrice,
        isService = isService
    })

    if (not enable and not startingMenu) then
        SaveToggleProps()
        oldPed = {}
        DestroyAllCams(true)
        RenderScriptCams(false, true, 1, true, true)
    end
end

function CustomCamera(position,ending)
    if startingMenu and position == "torso" then return end
    if not enabled then return end
    if customCam  then
        FreezePedCameraRotation(player, false)
        SetCamActive(cam, false)
        if not ending and not startingMenu then
            RenderScriptCams(false,  false,  0,  true,  true)
            if (DoesCamExist(cam)) then
               DestroyCam(cam, false)
            end
        end
        customCam = false
    else
        if (DoesCamExist(cam)) then
            DestroyCam(cam, false)
        end

        local pos = GetEntityCoords(player, true)
        if not startingMenu then
            SetEntityRotation(player, 0.0, 0.0, 0.0, 1, true)
        end

        FreezePedCameraRotation(player, true)

        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamCoord(cam, player)
        SetCamRot(cam, 0.0, 0.0, 0.0)

        SetCamActive(cam, true)
        RenderScriptCams(true,  false,  0,  true,  true)

        SwitchCam(position)
        customCam = true
    end
end

function rotation(dir)
    local pedRot = GetEntityHeading(PlayerPedId())+dir
    SetEntityHeading(PlayerPedId(), pedRot % 360)
end

function TogRotation()
    local pedRot = GetEntityHeading(PlayerPedId())+90 % 360
    SetEntityHeading(PlayerPedId(), math.floor(pedRot / 90) * 90.0)
end

function SwitchCam(name)
    if name == "cam" then
        TogRotation()
        return
    end

    local pos = GetEntityCoords(player, true)
    local bonepos = false
    if (name == "head") then
        bonepos = GetPedBoneCoords(player, 31086)
        if startingMenu then
            bonepos = vector3(bonepos.x - 0.7, bonepos.y + 0.0, bonepos.z + 0.05)
        else
            bonepos = vector3(bonepos.x - 0.1, bonepos.y + 0.4, bonepos.z + 0.05)
        end
        
    end
    if (name == "torso") then
        bonepos = GetPedBoneCoords(player, 11816)
        bonepos = vector3(bonepos.x - 0.4, bonepos.y + 2.2, bonepos.z + 0.2)
    end
    if (name == "leg") then
        bonepos = GetPedBoneCoords(player, 46078)

        if startingMenu then
            bonepos = vector3(bonepos.x - 0.9, bonepos.y + 0.0, bonepos.z-0.2)
        else
            bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
        end

    end

    SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
    if startingMenu and name ~= "torso" then
        SetCamRot(cam, 0.0, 0.0, 250.0)
    else
        SetCamRot(cam, 0.0, 0.0, 180.0)
    end
    
end

RegisterNetEvent("clothing:close")
AddEventHandler("clothing:close", function()
    EnableGUI(false, false)
end)

RegisterNUICallback('escape', function(data, cb)
    local shouldSave = data['save'] or false
    if shouldSave and currentPrice > 0 then
        local purchaseSuccess = RPC.execute("clothing:purchase", currentPrice)
        if not purchaseSuccess then 
            TriggerEvent("DoLongHudText", "You don't have enough money!")
            shouldSave = false
        end
    end
    if not startingMenu then
        TriggerServerEvent("Police:getMeta")
    end
    Save(shouldSave,true)
    cb('ok')
end)

RegisterNUICallback('togglecursor', function(data, cb)
    if not startingMenu then
        CustomCamera("torso")
        SetCustomNuiFocus(false, false)
        FreezePedCameraRotation(player, false)
    end
    cb('ok')
end)

RegisterNUICallback('rotate', function(data, cb)
    if (data["key"] == "left") then
        rotation(20)
    else
        rotation(-20)
    end
    cb('ok')
end)

RegisterNUICallback('switchcam', function(data, cb)
    CustomCamera(data['name'])
    cb('ok')
end)

RegisterNUICallback('toggleclothes', function(data, cb)
    ToggleProps(data)
    cb('ok')
end)


------------------------------------------------------------------------
-- Tattooooooos


-- currentTats [[collectionHash, tatHash], [collectionHash, tatHash]]
-- loop tattooHashList [categ] find [tatHash, collectionHash]

function GetTats()
    local tempTats = {}
    if currentTats == nil then return {} end
    for i = 1, #currentTats do
        for key in pairs(tattooHashList) do
            for j = 1, #tattooHashList[key] do
                if tattooHashList[key][j][1] == currentTats[i][2] then
                    tempTats[key] = j
                end
            end
        end
    end
    return tempTats
end

function SetTats(data)
    currentTats = {}
    for k, v in pairs(data) do
        for categ in pairs(tattooHashList) do
            if k == categ then
                local something = tattooHashList[categ][tonumber(v)]
                if something ~= nil then
                    table.insert(currentTats, {something[2], something[1]})
                end
            end
        end
    end
    ClearPedDecorations(PlayerPedId())
    for i = 1, #currentTats do
        ApplyPedOverlay(PlayerPedId(), currentTats[i][1], currentTats[i][2])
    end
end

RegisterNUICallback('settats', function(data, cb)
    SetTats(data["tats"])
    cb('ok')
end)


--------------------------------------------------------------------
-- Main menu

function OpenMenu(name, pPriceText, pPrice)
    player = PlayerPedId()
    oldPed = GetCurrentPed()
    local isAllowed = false
    if(oldPed.model == 1885233650 or oldPed.model == -1667301416) then isAllowed = true end
    if((oldPed.model ~= 1885233650 or oldPed.model ~= -1667301416) and (name == "clothing_shop" or name == "tattoo_shop")) then isAllowed = true end
    if isAllowed then
        FreezePedCameraRotation(player, true)
        RefreshUI()
        EnableGUI(true, name, pPriceText, pPrice)
        TriggerEvent("inmenu", true)
    else
        TriggerEvent("DoLongHudText", "You are not welcome here!");
    end
end

function Save(save, close)

    if save then

        data = GetCurrentPed()
        
        if (GetCurrentPed().model == GetHashKey("mp_f_freemode_01") or GetCurrentPed().model == GetHashKey("mp_m_freemode_01")) and startingMenu then
            -- nothing 
        else
            passedClothing = true
        end
        

        if not startingMenu or passedClothing then
            TriggerServerEvent("raid_clothes:insert_character_current", data)
            
            TriggerServerEvent("raid_clothes:insert_character_face", data)
            TriggerServerEvent("raid_clothes:set_tats", currentTats)
            TriggerEvent("drp-spawn:finishedClothing","Finished")
        elseif not passedClothing then 
            passedClothing = true
            Wait(2000)
            OpenMenu("barber_shop")
            return
        end
        
    else
        TriggerEvent("drp-spawn:finishedClothing","Old")
        LoadPed(oldPed)
    end

    if close then
        EnableGUI(false, false)
    end

    TriggerEvent("inmenu", false)
    TriggerEvent("ressurection:relationships:norevive")
    TriggerEvent("gangs:setDefaultRelations")
    TriggerEvent("facewear:update")
    TriggerEvent('drp-weapons:getAmmo')
    CustomCamera('torso',true)
    startingMenu = false
end

local showBarberShopBlips = false

RegisterNetEvent('hairDresser:ToggleHair')
AddEventHandler('hairDresser:ToggleHair', function()
   showBarberShopBlips = not showBarberShopBlips
   for _, item in pairs(barberShops) do
        if not showBarberShopBlips then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[2])
            SetBlipScale(item.blip, 0.7)
            SetBlipSprite(item.blip, 71)
            SetBlipColour(item.blip, 10)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Barber Shop")
            EndTextCommandSetBlipName(item.blip)
        end
    end
end)

function addBlips()
    TriggerEvent('hairDresser:ToggleHair')
end

local Clothing = {
    {-162.658, -303.397, 39.733},
    {75.950, -1392.891, 29.376},
    {-822.194, -1074.134, 11.328},
    {-1450.711, -236.83, 49.809},
    {4.254, 6512.813, 31.877},
    {615.180, 2762.933, 44.088},
    {1196.785, 2709.558, 38.222},
    {-3171.453, 1043.857, 20.863},
    {-1100.959, 2710.211, 19.107},
    {-1192.9453125, -772.62481689453, 17.3254737854},
    {-707.33416748047, -155.07914733887, 37.415187835693},
    {1683.45667, 4823.17725, 42.1631294},
    {-712.215881, -155.352982, 37.4151268},
    {121.76, -224.6, 54.56},
    {-1207.5267333984, -1456.9530029297, 4.3763856887817}
}

local showClothes = true

RegisterNetEvent('clothing:blips')
AddEventHandler('clothing:blips', function()
    showClothes = not showClothes
   for _, item in pairs(Clothing) do
        if not showClothes then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[3])
            SetBlipSprite(item.blip, 73)
            SetBlipScale(item.blip, 0.7)
			SetBlipColour(item.blip, 3)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Clothing Store")
            EndTextCommandSetBlipName(item.blip)
        end
    end
end)

Citizen.CreateThread(function()
    showClothes = false
    TriggerEvent('clothing:blips')
end)

RegisterNetEvent('raid_clothes:saveCharacterClothes')
AddEventHandler('raid_clothes:saveCharacterClothes', function()
    local data = GetCurrentPed()
    TriggerServerEvent("raid_clothes:insert_character_current", data)
end)

RegisterNetEvent('hairDresser:ToggleHair')
AddEventHandler('hairDresser:ToggleHair', function()
   showBarberShopBlips = not showBarberShopBlips
   for _, item in pairs(barberShops) do
        if not showBarberShopBlips then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[2])
            SetBlipScale(item.blip, 0.7)
            SetBlipSprite(item.blip, 71)
            SetBlipColour(item.blip, 10)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Barber Shop")
            EndTextCommandSetBlipName(item.blip)
        end
    end
end)

RegisterNetEvent('tattoo:ToggleTattoo')
AddEventHandler('tattoo:ToggleTattoo', function()
   showTattooShopBlips = not showTattooShopBlips
   for _, item in pairs(tattoosShops) do
        if not showTattooShopBlips then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[2])
            SetBlipSprite(item.blip, 75)
            SetBlipColour(item.blip, 1)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Tattoo Shop")
            EndTextCommandSetBlipName(item.blip)
        end
    end
end)

function addBlips()
    TriggerEvent('hairDresser:ToggleHair')
end

AddEventHandler("drp-base:initialSpawnModelLoaded", function()
    TriggerServerEvent("clothing:checkIfNew")
    TriggerServerEvent('drp-admin:AddPlayer')
    -- TriggerServerEvent('ABX-scoreboard:AddPlayer')
    TriggerEvent('house:keys')
    TriggerServerEvent("police:getAnimData")
    TriggerServerEvent("police:getEmoteData")
    TriggerServerEvent("police:getMeta")
    TriggerServerEvent("drp-weapons:getAmmo")
    TriggerServerEvent("trucker:returnCurrentJobs")
    TriggerServerEvent("police:SetMeta")
    TriggerEvent("reviveFunction")
    TriggerServerEvent("kGetWeather")

end)

RegisterNetEvent("raid_clothes:inService")
AddEventHandler("raid_clothes:inService", function(service)
    isService = service
end)

RegisterNetEvent("raid_clothes:hasEnough")
AddEventHandler("raid_clothes:hasEnough", function(menu)
    if menu == "tattoo_shop" then
        TriggerServerEvent("raid_clothes:retrieve_tats")
        while currentTats == nil do
            Citizen.Wait(1)
        end
    end

    OpenMenu(menu)
end)

RegisterNetEvent("raid_clothes:admin:open")
AddEventHandler("raid_clothes:admin:open", function(name)
    OpenMenu(name)
end)

RegisterNetEvent("raid_clothes:setclothes")
AddEventHandler("raid_clothes:setclothes", function(data,alreadyExist)
    player = PlayerPedId()
    local function setDefault()
        --- decapritated function
    end

	if not data.model and alreadyExist <= 0 then setDefault() return end
    if not data.model and alreadyExist >= 1 then return end
    model = data.model
    model = model ~= nil and tonumber(model) or false

	if not IsModelInCdimage(model) or not IsModelValid(model) then setDefault() return end
    SetSkin(model, false)
    Citizen.Wait(500)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
	TriggerEvent("facewear:update")
    TriggerServerEvent("raid_clothes:get_character_face")
    TriggerServerEvent("raid_clothes:retrieve_tats")
	TriggerServerEvent("Police:getMeta")
    TriggerEvent("Animation:Set:Reset")
    TriggerEvent("e-blips:updateAfterPedChange",exports["isPed"]:isPed("myjob"))
end)

RegisterNetEvent("raid_clothes:AdminSetModel")
AddEventHandler("raid_clothes:AdminSetModel", function(model)
    local hashedModel = GetHashKey(model)
    if not IsModelInCdimage(hashedModel) or not IsModelValid(hashedModel) then return end
    SetSkin(hashedModel, true)
end)

RegisterNetEvent("raid_clothes:defaultReset")
AddEventHandler("raid_clothes:defaultReset", function()
    local LocalPlayer = exports["drp-base"]:getModule("LocalPlayer")
    local gender = LocalPlayer:getCurrentCharacter().gender
    Citizen.Wait(1000)
    if gender ~= 0 then
        SetSkin(`mp_f_freemode_01`, true)
    else
        SetSkin(`mp_m_freemode_01`, true)
    end
    OpenMenu("clothing_shop")
    startingMenu = true
    passedClothing = false
end)

RegisterNetEvent("raid_clothes:settattoos")
AddEventHandler("raid_clothes:settattoos", function(playerTattoosList)
    currentTats = playerTattoosList
    SetTats(GetTats())
end)

RegisterNetEvent("raid_clothes:setpedfeatures")
AddEventHandler("raid_clothes:setpedfeatures", function(data)
    player = PlayerPedId()
    if data == false then
        SetSkin(GetEntityModel(PlayerPedId()), true)
        return
    end
    local head = data.headBlend
    local haircolor = data.hairColor

    -- print("setpedfeatures ---------------------------------")
    -- for i in pairs(data) do
    --     if (#data[i] > 0) then
    --         for k in pairs(data[i]) do
    --             print(json.encode(data[i][k]))
    --         end
    --     else
    --         print(json.encode(data[i]))
    --     end
    -- end

    SetPedHeadBlendData(player,
        tonumber(head['shapeFirst']),
        tonumber(head['shapeSecond']),
        tonumber(head['shapeThird']),
        tonumber(head['skinFirst']),
        tonumber(head['skinSecond']),
        tonumber(head['skinThird']),
        tonumber(head['shapeMix']),
        tonumber(head['skinMix']),
        tonumber(head['thirdMix']),
        false)
    SetHeadStructure(data.headStructure)
    SetPedHairColor(player, tonumber(haircolor[1]), tonumber(haircolor[2]))
    SetHeadOverlayData(data.headOverlay)
end)

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('raid_clothes:outfits')
AddEventHandler('raid_clothes:outfits', function(pAction, pId, pName)
    if pAction == 1 then
        TriggerServerEvent("raid_clothes:set_outfit",pId, pName, GetCurrentPed())
    elseif pAction == 2 then
        TriggerServerEvent("raid_clothes:remove_outfit",pId)
    elseif pAction == 3 then 
        TriggerEvent("hud:saveCurrentMeta")
        TriggerEvent('item:deleteClothesDna')
        TriggerEvent('InteractSound_CL:PlayOnOne','Clothes1', 0.6)
        TriggerServerEvent("raid_clothes:get_outfit", pId)
    else
        TriggerServerEvent("raid_clothes:list_outfits")
    end
end)

--// Glasses Commands

RegisterCommand("g1", function(source, args, rawCommand)
    TriggerEvent("facewear:adjust",2,false)
end, false)

RegisterCommand("g0", function(source, args, rawCommand)
    TriggerEvent("facewear:adjust",2,true)
end, false)

--// Mask Commands

RegisterCommand("m1", function(source, args, rawCommand)
    if exports['drp-inventory']:hasEnoughOfItem('mask', 1) then
        TriggerEvent("facewear:adjust",4,false)   
        TriggerEvent('inventory:removeItem', 'mask', 1)
    else
        TriggerEvent('DoLongHudText', 'You need a mask, buy one at the clothing store', 2)
    end
end, false)

RegisterCommand("m0", function(source, args, rawCommand)
    if exports['drp-inventory']:hasEnoughOfItem('mask', 1) then
        TriggerEvent("facewear:adjust",4,true)
    else
        TriggerEvent('player:receiveItem', "mask", 1)
        TriggerEvent("facewear:adjust",4,true)
    end
end, false)

--// Vest Command

RegisterCommand("vest", function(source, args, rawCommand)
    if GetPedDrawableVariation(PlayerPedId(), 9) ~= 0 then
        TriggerEvent("facewear:adjust",7,true)
    elseif GetPedDrawableVariation(PlayerPedId(), 9) == 0 or GetPedDrawableVariation(PlayerPedId(), 9) == -1 then
        TriggerEvent("facewear:adjust",7,false)
    end
end, false)

--// Hat Commands

RegisterCommand("h1", function(source, args, rawCommand)
    if exports['drp-inventory']:hasEnoughOfItem('hat', 1) then
        TriggerEvent("facewear:adjust",6,false)
        TriggerEvent('inventory:removeItem', 'hat', 1)
    else
        TriggerEvent('DoLongHudText', 'You need a hat, get one from the clothing store', 2)
    end
end, false)

RegisterCommand("h0", function(source, args, rawCommand)
    if exports['drp-inventory']:hasEnoughOfItem('hat', 1) then
        TriggerEvent("facewear:adjust",6,true)
    else
        TriggerEvent('player:receiveItem', "hat", 1)
        TriggerEvent("facewear:adjust",6,true)
    end
end, false)

RegisterUICallback("drp-ui:raid_clothes:addOutfitPrompt", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    Wait(1) --wait to fix ui bug?
    exports['drp-ui']:openApplication('textbox', {
        callbackUrl = 'drp-ui:raid_clothes:addOutfit',
        header = "Add Outfit",
        key = data.key,
        items = {
            {
                icon = "pencil-alt",
                label = "Outfit Number",
                name = "outfitSlot",
            },
            {
                icon = "pencil-alt",
                label = "Outfit Name",
                name = "outfitName",
            },
        },
        show = true,
    })
end)

RegisterUICallback("drp-ui:raid_clothes:addOutfit", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = '' } })
    exports['drp-ui']:closeApplication('textbox')
    local outfitSlot = data[1].value
    local outfitName = data[2].value
    if outfitName == nil then outfitName = "Outfit" end
    
    TriggerServerEvent("raid_clothes:set_outfit", outfitSlot, outfitName, GetCurrentPed())
end)

RegisterUICallback("drp-ui:raid_clothes:changeOutfit", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    TriggerEvent('hotel:outfit', { true, data.key }, 3)
end)

RegisterUICallback("drp-ui:raid_clothes:deleteOutfit", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    TriggerEvent('hotel:outfit', { true, data.key }, 2)
end)

RegisterNetEvent('raid_clothes:ListOutfits')
AddEventHandler('raid_clothes:ListOutfits', function(skincheck)
    local menuData = {}
    local takenSlots = {}
    for i = 1, #skincheck do
        local slot = tonumber(skincheck[i].slot)
        takenSlots[slot] = true
        menuData[#menuData + 1] = {
            title = slot .. " | " .. skincheck[i].name,
            description = '',
            key = slot,
            children = {
                { title = "Change Outfit", action = "drp-ui:raid_clothes:changeOutfit", key = slot},
                { title = "Delete Outfit", action = "drp-ui:raid_clothes:deleteOutfit", key = slot},
            }
        }
    end
    if #menuData >= 0 then
        if #menuData < 20 then
            --Find first empty slot
            local emptySlot = -1
            for i=1,20 do
                if emptySlot == -1 and takenSlots[i] == nil then
                    emptySlot = i
                end
            end
            menuData[#menuData + 1] = {
                title = "Save Current Outfit",
                description = '',
                key = emptySlot,
                action = "drp-ui:raid_clothes:addOutfitPrompt"
            }
        end
        exports['drp-ui']:showContextMenu(menuData)
    else
        TriggerEvent("DoLongHudText", "No saved outfits", 2)
    end
end)

-- LoadPed(data) Sets clothing based on the data structure given, the same structure that GetCurrentPed() returns
-- GetCurrentPed() Gives you the data structure of the currently worn clothes

function SetCustomNuiFocus(hasKeyboard, hasMouse)
  HasNuiFocus = hasKeyboard or hasMouse
  SetNuiFocus(hasKeyboard, hasMouse)
  --SetNuiFocusKeepInput(HasNuiFocus)

  -- TriggerEvent("drp-voice:focus:set", HasNuiFocus, hasKeyboard, hasMouse)
end


Citizen.CreateThread(function()
    addBlips()
    SetCustomNuiFocus(false, false)


    while true do
        Wait(0)
        if enabled then
            if (IsControlJustReleased(1, 25)) then
                SetCustomNuiFocus(true, true)
                FreezePedCameraRotation(player, true)
            end
            if (IsControlJustReleased(1, 202)) then
                SetCustomNuiFocus(true, true)
                FreezePedCameraRotation(player, true)
            end
            InvalidateIdleCam()
        end
    end
end)

local function listenForKeypress(zoneName, zoneData, isFree)
    listening = true
    Citizen.CreateThread(function()
        while listening do
            if IsControlJustReleased(0, 244) then
                if zoneName == "tattoo_shop" then
                    TriggerServerEvent("drp-clothingmenu:retrieve_tats")
                    while currentTats == nil do
                        Citizen.Wait(0)
                    end
                end
                OpenMenu(zoneName, 0, 0)

                exports['drp-textui']:hideInteraction()
            end
            Wait(0)
        end
    end)
end

local facialWear = {
	[1] = { ["Prop"] = -1, ["Texture"] = -1 },
	[2] = { ["Prop"] = -1, ["Texture"] = -1 },
	[3] = { ["Prop"] = -1, ["Texture"] = -1 },
	[4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
	[5] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
	[6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
    [7] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
}

RegisterNetEvent("facewear:update")
AddEventHandler("facewear:update",function()
	for i = 0, 3 do
		if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
			facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
		end
		if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
			facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
		end
	end

	if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
		facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
		facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
		facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
	end

	if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
		facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
		facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
		facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
	end
end)


RegisterNetEvent("facewear:adjust")
AddEventHandler("facewear:adjust",function(faceType,remove)
	local handcuffed = exports["isPed"]:isPed("handcuffed")
	if handcuffed then return end
	local AnimSet = "none"
	local AnimationOn = "none"
	local AnimationOff = "none"
	local PropIndex = 0

	local AnimSet = "mp_masks@on_foot"
	local AnimationOn = "put_on_mask"
	local AnimationOff = "put_on_mask"


	for i = 0, 3 do
		if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
			facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
		end
		if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
			facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
		end
	end

	if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
		facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
		facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
		facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
	end

	if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
		facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
		facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
		facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
	end



	if faceType == 1 then
		PropIndex = 0
	elseif faceType == 2 then
		PropIndex = 1

		AnimSet = "clothingspecs"
		AnimationOn = "take_off"
		AnimationOff = "take_off"

	elseif faceType == 3 then
		PropIndex = 2
	elseif faceType == 4 then
		PropIndex = 1
		if remove then
			AnimSet = "missfbi4"
			AnimationOn = "takeoff_mask"
			AnimationOff = "takeoff_mask"
		end
	elseif faceType == 5 then
		PropIndex = 11
		AnimSet = "oddjobs@basejump@ig_15"
		AnimationOn = "puton_parachute"
		AnimationOff = "puton_parachute"	
		--mp_safehouseshower@male@ male_shower_idle_d_towel
		--mp_character_creation@customise@male_a drop_clothes_a
		--oddjobs@basejump@ig_15 puton_parachute_bag
	elseif faceType == 7 then
		PropIndex = 9
		AnimSet = "clothingshirt"
		AnimationOn = "try_shirt_positive_d"
		AnimationOff = "try_shirt_positive_d"	

	end

	loadAnimDict( AnimSet )
	if faceType == 5 then
		if remove then
			SetPedComponentVariation(PlayerPedId(), 3, 2, facialWear[6]["Texture"], facialWear[6]["Palette"])
		end
	end
	if remove then
		TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
		Citizen.Wait(500)
		if faceType ~= 5 then
			if faceType == 4 then
				SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
			else
				if faceType ~= 2 then
					ClearPedProp(PlayerPedId(), tonumber(PropIndex))
				end
			end
		end
	else
		TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
		Citizen.Wait(500)
		if faceType ~= 5 and faceType ~= 2 and faceType ~= 7 then
			if faceType == 4 then
				SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[faceType]["Prop"], facialWear[faceType]["Texture"], facialWear[faceType]["Palette"])
			else
				SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
			end
		end
	end
	if faceType == 5 then
		if not remove then
			SetPedComponentVariation(PlayerPedId(), 3, 1, facialWear[6]["Texture"], facialWear[6]["Palette"])
			SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[faceType]["Prop"], facialWear[faceType]["Texture"], facialWear[faceType]["Palette"])
		else
			SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
		end
		Citizen.Wait(1800)
	end
	if faceType == 2 then
		Citizen.Wait(600)
		if remove then
			ClearPedProp(PlayerPedId(), tonumber(PropIndex))
		end

		if not remove then
			Citizen.Wait(140)
			SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
		end
	end
	if faceType == 4 and remove then
		Citizen.Wait(1200)
	end

	if faceType == 7 then
		Citizen.Wait(600)
		if remove then
			facialWear[7]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 9)
			facialWear[7]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 9)
			facialWear[7]["Texture"] = GetPedTextureVariation(PlayerPedId(), 9)
			SetPedComponentVariation(GetPlayerPed(-1), tonumber(PropIndex), 0, 0, false)
		end

		if not remove then
			Citizen.Wait(140)
			-- SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
			SetPedComponentVariation(GetPlayerPed(-1), tonumber(PropIndex), tonumber(facialWear[7]["Prop"]), tonumber(facialWear[7]["Texture"]), false)
			-- SetPedComponentVariation(GetPlayerPed(-1), tonumber(PropIndex), 4, 0, false)
		end
	end
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('raid_clothes:openClothing')
AddEventHandler('raid_clothes:openClothing', function(pDontShowBarber, pShouldCost)
    if pShouldCost ~= nil and pShouldCost then
        OpenMenu("clothing_shop", 0, 0)
        startingMenu = false
    else
        currentPrice = 0
        OpenMenu("clothing_shop", currentPrice, 0)
        startingMenu = true
    end
    passedClothing = pDontShowBarber or false
end)

AddEventHandler("drp-polyzone:enter", function(zone, data)
    local currentZone = MenuData[zone]
    if currentZone then
        exports['drp-textui']:showInteraction(("[M] %s"):format(currentZone.text))
        listenForKeypress(zone, currentZone, ((data and data.isFree) and true or false))
    end
end)

AddEventHandler("drp-polyzone:exit", function(zone)
    local currentZone = MenuData[zone]
    if currentZone then
        listening = false
        exports['drp-textui']:hideInteraction()
    end
end)

local hairTied = false
local currentHairStyle = nil
local supportedModels = {
  [`mp_f_freemode_01`] = 4,
  [`mp_m_freemode_01`] = 2,
}
AddEventHandler("drp-inventory:itemUsed", function(item)
    if item ~= "hairtie" then return end
    local hairValue = supportedModels[GetEntityModel(PlayerPedId())]
    if hairValue == nil then return end
    TriggerEvent("animation:PlayAnimation", "hairtie")
    Wait(1000)
    if not hairTied then
        hairTied = true
        local draw = GetPedDrawableVariation(PlayerPedId(), 2)
        local text = GetPedTextureVariation(PlayerPedId(), 2)
        local pal = GetPedPaletteVariation(PlayerPedId(), 2)
        currentHairStyle = { draw, text, pal }
        SetPedComponentVariation(PlayerPedId(), 2, hairValue, text, pal)
    else
        hairTied = false
        SetPedComponentVariation(PlayerPedId(), 2, currentHairStyle[1], currentHairStyle[2], currentHairStyle[3])
    end
end)



---- WIP----
local inmenucustom = false
RegisterNetEvent("raid_clothes:setclothessss")
AddEventHandler("raid_clothes:setclothessss", function(data,alreadyExist)
    player = PlayerPedId()
    -- local function setDefault()
    --     --- decapritated function
    -- end
    Citizen.Wait(500)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
	TriggerEvent("facewear:update")
    TriggerServerEvent("raid_clothes:get_character_face")
    TriggerServerEvent("raid_clothes:retrieve_tats")
	TriggerServerEvent("Police:getMeta")
    TriggerEvent("Animation:Set:Reset")
    TriggerEvent("e-blips:updateAfterPedChange",exports["isPed"]:isPed("myjob"))
end)

--- addd pricing adding function
RegisterNetEvent("raid_clothes:set_sale_outfit")
AddEventHandler("raid_clothes:set_sale_outfit", function(name,price)
    if name and price then
        TriggerServerEvent("raid_clothes:set_outfit_for_sale", name, price, GetCurrentPed())
    end
end)

RegisterNetEvent("raid_clothes_get_meta")
AddEventHandler("raid_clothes_get_meta", function(name)
    RPC.execute("raid_clothes:get_custom_outfits_confirmation",name)
end)

RegisterNetEvent("raid_clothes:open_customs")
AddEventHandler("raid_clothes:open_customs", function()
    inmenucustom = true
    RPC.execute("raid_clothes:get_custom_outfits")
    TriggerServerEvent("raid_clothes:get_character_current_for_customs")
end)

RegisterNetEvent("clothing:client:thinkingstarts")
AddEventHandler("clothing:client:thinkingstarts", function()
    -- TriggerServerEvent("raid_clothes:get_character_current_for_customs")
    -- RPC.execute("raid_clothes:get_custom_outfits")
end)

RegisterNetEvent("raid_clothes:bought_customs")
AddEventHandler("raid_clothes:bought_customs", function(id)
    inmenucustom = false
    RPC.execute("raid_clothes:bought_customs",id)
end)

RegisterNetEvent("drp-context:closeglobal")
AddEventHandler("drp-context:closeglobal", function()
    if inmenucustom then
        inmenucustom = false
        TriggerServerEvent("raid_clothes:get_character_current_for_customs")
    end
end)

RegisterNetEvent("raid_clothes:save_customs")
AddEventHandler("raid_clothes:save_customs", function()
    local data = {
        {
            title = "Put Outfit For Sale",
            description = "",
            key = true,
            action = "drp-ui:raid_clothes:CustomaddOutfitPrompt"
        },
    }

    exports["drp-ui"]:showContextMenu(data)
end)

RegisterUICallback("drp-ui:raid_clothes:CustomaddOutfitPrompt", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    Wait(1) --wait to fix ui bug?
    exports['drp-ui']:openApplication('textbox', {
        callbackUrl = 'drp-ui:raid_clothes:addCustomOutfit',
        key = data.key,
        items = {
            {
                icon = "pencil-alt",
                label = "Outfit Name",
                name = "outfitName",
            },
            {
                icon = "pencil-alt",
                label = "Outfit Price",
                name = "outfitSlot",
            },           
        },
        show = true,
    })
end)

RegisterUICallback("drp-ui:raid_clothes:addCustomOutfit", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = '' } })
    exports['drp-ui']:closeApplication('textbox')
    local Name = data[1].value
    local Price = data[2].value
    -- if outfitName == nil then outfitName = "" end
    SetNuiFocus(false, false)
    exports["drp-ui"]:hideContextMenu()
    --TriggerServerEvent("raid_clothes:set_outfit", outfitSlot, outfitName, GetCurrentPed())
    TriggerEvent("raid_clothes:set_sale_outfit",Name,Price)
    SetNuiFocus(false, false)
end)

local attachedProps = {}
function removeAttachedProp()
  for _, v in pairs(attachedProps) do
    DeleteEntity(v)
  end
  attachedProps = {}
end
function attachProp(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR, keepOtherProps, altVertex)
  if not keepOtherProps then
    removeAttachedProp()
  end
  attachModel = GetHashKey(attachModelSent)
  boneNumber = boneNumberSent
  local bone = GetPedBoneIndex(PlayerPedId(), boneNumberSent)
  RequestModel(attachModel)
  while not HasModelLoaded(attachModel) do
    Citizen.Wait(0)
  end
  local attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
  attachedProps[#attachedProps + 1] = attachedProp
  AttachEntityToEntity(attachedProp, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 1, not altVertex and 2 or 0, 1)
  SetModelAsNoLongerNeeded(attachModel)
end

AddEventHandler("drp-props:attachProp", function(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR, keepOtherProps, altVertex)
  attachProp(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR, keepOtherProps, altVertex)
end)
AddEventHandler("drp-props:removeProp", function()
  removeAttachedProp()
end)


local hasCgChainOn = false
local equippingChain = false
local chainModels = {
    ["cgchain"] = "cg_chain",
    ["gsfchain"] = "gsf_chain",
    ["cerberuschain"] = "cerberus_chain",
    ["mdmchain"] = "mdm_chain",
    ["vagoschain"] = "esv_chain",
    ["koilchain"] = "koil_chain",
}
local storedpItem = false
local storedpInfo = false

AddEventHandler("drp-inventory:itemUsed", function(pItem, pInfo)
  storedpItem = pItem
  storedpInfo = pInfo
  local model = chainModels[pItem]
  if not model then return end
  if equippingChain then return end
  local info = json.decode(pInfo)
  equippingChain = true
  TriggerEvent("animation:PlayAnimation", "chainon")
  Wait(2600)
  if not hasCgChainOn then
    hasCgChainOn = true
    -- SetPedComponentVariation(PlayerPedId(), 7, chainValue, 0, 0)
    TriggerEvent("drp-props:attachProp", model, 10706, -0.01, 0.00, -0.05, -366.0, 19.0, -163.0, true, true)
    Citizen.CreateThread(function()
      while hasCgChainOn do
        print(here)
        Citizen.Wait(math.random(10000, 120000))
        -- if info.diamond then
        --   local gemInfo = exports['raid_clothes']:getGemData(info.diamond)
        --   TriggerServerEvent("drp-fx:chain:blingDiamonds", GetEntityCoords(PlayerPedId()), "diamonds", gemInfo.count, 100)
        -- end
        Citizen.Wait(math.random(10000, 60000))
      end
    end)
    Citizen.CreateThread(function()
      while hasCgChainOn do
        Citizen.Wait(math.random(10000, 120000))
        -- if info.ruby then
        --   local gemInfo = exports['raid_clothes']:getGemData(info.ruby)
        --   TriggerServerEvent("drp-fx:chain:blingDiamonds", GetEntityCoords(PlayerPedId()), "ruby", gemInfo.count, 100)
        -- end
      end
    end)
    Citizen.CreateThread(function()
      while hasCgChainOn do
        Citizen.Wait(math.random(10000, 120000))
        -- if info.tanzanite then
        --   local gemInfo = exports['raid_clothes']:getGemData(info.tanzanite)
        --   TriggerServerEvent("drp-fx:chain:blingDiamonds", GetEntityCoords(PlayerPedId()), "tanzanite", gemInfo.count, 100, 0.25)
        -- end
      end
    end)
  else
    hasCgChainOn = false
    -- SetPedComponentVariation(PlayerPedId(), 7, -1, 0, 0)
    TriggerEvent("drp-props:removeProp")
  end
  equippingChain = false
end)

local hasSquidMaskOn = false
local equippingMask = false
local maskModels = {
  ["squidmask"] = { model = "np_squid_vip", x = 0.017, y =  0.015, z = -0.005 },
  ["varhelmet"] = { model = "np_vr_headset", x = 0.11, y = 0.04, z = 0.0 },
}

-- local hadattachitem = false

-- RegisterNetEvent('attachedItems:block')
-- AddEventHandler('attachedItems:block', function(status)
--     if (hasCgChainOn or hasSquidMaskOn) and status then
--         hadattachitem = true
--         hasCgChainOn = false
--         hasSquidMaskOn = false
--         -- its possible to stack both chain and hat on, so this is triggered twice.. might be worth rewriting this pile of shit prop system so it can handle multiple items on/off seperately too
--         TriggerEvent("drp-props:removeProp")
--         TriggerEvent("drp-props:removeProp")
--     elseif (hadattachitem) and not status then
--         hadattachitem = false
--         TriggerEvent("drp-inventory:itemUsed",storedpItem, storedpInfo)
--     end
-- end)



AddEventHandler("drp-inventory:itemUsed", function(pItem, pInfo)
  storedpItem = pItem
  storedpInfo = pInfo
  local model = maskModels[pItem]
  if not model then return end
  if equippingMask then return end
  local info = json.decode(pInfo)
  equippingMask = true
  TriggerEvent("animation:PlayAnimation", "chainon")
  Wait(2600)
  if not hasSquidMaskOn then
    hasSquidMaskOn = true
    -- SetPedComponentVariation(PlayerPedId(), 7, chainValue, 0, 0)
    TriggerEvent("drp-props:attachProp", model.model, 31086, model.x, model.y, model.z, -13.0, -86.0, -165.0, true, true)
  else
    hasSquidMaskOn = false
    TriggerEvent("drp-props:removeProp")
  end
  equippingMask = false
end)

RegisterNetEvent("drp-inventory:itemCheck", function(item)
  local model = chainModels[item]
  if not model then return end
  local qty = exports["drp-inventory"]:hasEnoughOfItem(item, 1)
  if qty then return end
  hasCgChainOn = false
  TriggerEvent("drp-props:removeProp")
end)





-- Small and simple 
-- TO DO : Change the inventory picture on shared list , Add a custom chain texture  

  local AllowedPeds = {
    [`mp_f_freemode_01`] = 4,
    [`mp_m_freemode_01`] = 2,
  }

  local isChainOn = false


  RegisterNetEvent("ghost:togglechain")
  AddEventHandler("ghost:togglechain", function()
    local playerPed = PlayerPedId()
    local allowedmodels = AllowedPeds[GetEntityModel(PlayerPedId())]
    if allowedmodels then
    if not isChainOn then
    TriggerEvent("animation:PlayAnimation", "chainon")
    Wait(2000)
    isChainOn = true
    SetPedComponentVariation(PlayerPedId(), 7, 54, 0, 0)
    else
    TriggerEvent("animation:PlayAnimation", "chainon")
    Wait(2000)
    isChainOn = false
    SetPedComponentVariation(PlayerPedId(), 7, -1, 0, 0)
   end
  end
end)

RegisterNetEvent('royal:clothing:admin', function()
    OpenMenu("clothing_shop")
end)