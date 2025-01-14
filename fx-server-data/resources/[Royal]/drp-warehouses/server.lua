local x = false

RegisterNetEvent("houses:confirmwarehouse")
AddEventHandler("houses:confirmwarehouse", function(warehouses)
    src = source
    local user = exports["drp-base"]:getModule("Player"):GetUser(src)
    local characterId = user:getCurrentCharacter().id
    for i, warehouse in pairs(warehouses) do  
        exports.ghmattimysql:execute("SELECT * FROM `houses2` WHERE keyname = ?", {warehouses[i]["keyName"]}, function(data)
            if not data[1] and x == false then
                x = true
                insert(i, warehouses)
                TriggerClientEvent("houses:finishuywarehouse", src, warehouses[i]["keyName"])
            end
        end)
    end

    if x == false then
        TriggerClientEvent("DoLongHudText", src, "There are no Warehouses availble right now!", 2)
    end
end)


function insert(i, warehouses)
    exports.ghmattimysql:execute('INSERT INTO `houses2` (cid, keyname, Name) VALUES (@cid, @keyname, @Name)',{
        ['@cid'] = characterId,
        ['@keyname'] = warehouses[i]["keyName"],
        ['@Name'] = warehouses[i]["locationName"],
    })
end