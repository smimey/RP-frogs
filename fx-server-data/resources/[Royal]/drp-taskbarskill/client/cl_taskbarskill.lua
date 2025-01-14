--[[

    Variables

]]

local tbsListening = false

local keyToCode = {
  ["1"] = 157,
  ["2"] = 158,
  ["3"] = 160,
  ["4"] = 164
}

--[[

    Functions

]]

function taskBarSkillCheck(difficulty, skillGapSent, cb, reverse, usePrev)
    TriggerEvent("menu:menuexit")

    if tbsListening then
        cb(0)
        return 0
    end

    local duration = difficulty --[[* (math.min(exports["drp-buffs"]:getAlertLevelMultiplier(), 1.33))]]

    local skillTick = usePrev and prevSkillCheck or 0
    local speed = (100.0 / duration)
    local key = tostring(math.random(1,4))
    local moveCursor = true
    local cursorRot = 0

    local originX, originY = 0.5, 0.585
    local screenX, screenY = GetActiveScreenResolution()

    local spriteW = 128.0 / 1920.0
    local spriteH = 128.0 / 1080.0

    local bgColor = { r = 37, g = 50, b = 56 }
    local hudColor = { r = 248, g = 185, b = 0 }
    local cursorColor = { r = 220, g = 0, b = 0 }

    local function skillToSprite(skill)
        if skill <= 5 then
            return "skill_5", 7
        end
        if skill <= 7 then
            return "skill_7", 10
        end
        if skill <= 10 then
            return "skill_10", 13
        end
        if skill <= 12 then
            return "skill_12", 15
        end
        if skill <= 15 then
            return "skill_15", 18
        end
        if skill <= 17 then
            return "skill_17", 20
        end
        if skill <= 20 then
            return "skill_20", 25
        end
        if skill > 20 then
            return "skill_25", 30
        end
        if skill >= 30 then
            return "skill_30", 40
        end
    end

    local targetRotation = math.random(120,240) + 0.0
    local _,spriteGap = skillToSprite(skillGapSent)
    local targetBuffer = 6.0
    local targetGap = ((360 / 128) * math.floor((spriteGap / 128) * 100)) + targetRotation + targetBuffer
    local skillHandicapForPepegaStreamers = 2

    local didPass = targetRotation + targetBuffer <= (skillTick < 0 and 360 - skillTick or skillTick)

    local function drawKey(key)
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0, 1.25)
        SetTextDropshadow(10, 0, 0, 0, 255)
        SetTextOutline()
        SetTextFont(4)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentSubstringPlayerName(key)
        EndTextCommandDisplayText(originX, originY)
    end

    RequestStreamedTextureDict("caue_sprites", true)
    local timeout = GetGameTimer() + 10000
    while not HasStreamedTextureDictLoaded("caue_sprites") do
        if GetGameTimer() > timeout then
            cb(100)
            return 100
        end
        Wait(0)
    end

    local timer = GetGameTimer()
    tbsListening = true
    local minigameResult = 0
    guiEnabled = true
    SetNuiFocus(true, true)
    while tbsListening do
        local delta = GetGameTimer() - timer
        timer = GetGameTimer()

        DisableControlAction(0, 157, true)
        DisableControlAction(0, 158, true)
        DisableControlAction(0, 159, true)
        DisableControlAction(0, 160, true)
        DisableControlAction(0, 161, true)
        DisableControlAction(0, 162, true)


        skillTick = moveCursor and skillTick + (delta * speed * (reverse and -1 or 1)) or skillTick
        cursorRot = skillTick / 100 * 360

        SetScriptGfxDrawOrder(7)
        drawKey(key)
        -- background
        DrawSprite("caue_sprites", "circle_128", originX, originY + (spriteH / 3), spriteW, spriteH, 0, bgColor.r, bgColor.g, bgColor.b, 255)

        SetScriptGfxDrawOrder(9)
        -- draw target with skill gap width
        DrawSprite("caue_sprites", skillToSprite(skillGapSent), originX, originY + (spriteH / 3.0), spriteW, spriteH, targetRotation, hudColor.r, hudColor.g, hudColor.b, 255)

        SetScriptGfxDrawOrder(8)
        -- cursor
        DrawSprite("caue_sprites", "cursor_128", originX, originY + (spriteH / 3), spriteW, spriteH, cursorRot, cursorColor.r, cursorColor.g, cursorColor.b, 255)

        SetScriptGfxDrawOrder(1)

        for num,code in pairs(keyToCode) do
            if moveCursor and IsDisabledControlJustPressed(0, code) then
                local cursorPos = (cursorRot < 0 and 360 + cursorRot or cursorRot)
                if num == key and cursorPos >= (targetRotation + targetBuffer) and cursorPos <= (targetGap + skillHandicapForPepegaStreamers) then
                    minigameResult = 100
                    hudColor = { r = 0, g = 255, b = 0 }
                else
                    minigameResult = 0
                    hudColor = { r = 255, g = 0, b = 0 }
                end
                moveCursor = false
                SetTimeout(250, function()
                    tbsListening = false
                end)
            end
        end

        if IsDisabledControlJustPressed(0, 200) then
            tbsListening = false
            minigameResult = 0
        end

        if (not reverse and skillTick >= 100 and not didPass) or (reverse and skillTick <= -100 and not didPass) then
            minigameResult = 0
            tbsListening = false
        end

        if skillTick > 100 or skillTick < -100 then
            didPass = false
            skillTick = 0
        end

        if IsPedRagdoll(PlayerPedId()) then
            tbsListening = false
            minigameResult = 0
        end

        Wait(0)
    end

    prevSkillCheck = usePrev and skillTick or nil

    SetTimeout(500, function()
        if not tbsListening then
            guiEnabled = false
            SetNuiFocus(false, false)
            SetStreamedTextureDictAsNoLongerNeeded("caue_sprites")
        end
    end)

    if cb then
        cb(minigameResult)
    end

    return minigameResult
end

--[[

    Exports

]]

exports("taskBarSkill", taskBarSkillCheck)