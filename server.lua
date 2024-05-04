local QBCore = exports['qb-core']:GetCoreObject()

local someCheck = {}

RegisterServerEvent('erp-fish:takeMoney')
AddEventHandler('erp-fish:takeMoney', function(money)
    if money == 1 then
        local _source = source
        local xPlayer  = QBCore.Functions.GetPlayer(_source)
        local ped = GetPlayerPed(_source)
        local pedLocation = GetEntityCoords(ped)
        if #(vector3(-178.63, 314.34, 96.97) - pedLocation) <= 5.25 or #(vector3(-645.99, -1223.77, 10.22) - pedLocation) <= 5.25 or #(vector3(3865.944, 4463.568, 2.73844) - pedLocation) <= 20.0 or #(vector3(-3424.41, 982.81, 8.43) - pedLocation) <= 20.0 or #(vector3(1302.839, 4225.832, 33.9087) - pedLocation) <= 20.0 then
            someCheck[xPlayer.PlayerData.citizenid] = true
        end
    end
end)

RegisterServerEvent('erp-fish:payShit')
AddEventHandler('erp-fish:payShit', function(money)
    local _source = source
    local xPlayer  = QBCore.Functions.GetPlayer(_source)
    local ped = GetPlayerPed(_source)
    local pedLocation = GetEntityCoords(ped)
    if someCheck[xPlayer.PlayerData.citizenid] then
        someCheck[xPlayer.PlayerData.citizenid] = false
        if #(vector3(-178.63, 314.34, 96.97) - pedLocation) <= 5.25 or #(vector3(-645.99, -1223.77, 10.22) - pedLocation) <= 5.25 then
            if money ~= nil then
                xPlayer.Functions.AddMoney("cash", money)
            end
        else
            TriggerEvent('logger:log', 'Possible Hack Attempt', xPlayer.getLegalName() .. ' attempted to receive money from the fishing job. Wrong location', _source, 'Hack', 'Hack', 1, 'Fish Job')
        end
    else
        TriggerEvent('logger:log', 'Possible Hack Attempt', xPlayer.getLegalName() .. ' attempted to receive money from the fishing job. Did not do the fish check or does not have proper fish amount', _source, 'Hack', 'Hack', 1, 'Fish Job')
    end
end)

RegisterServerEvent('fish:checkAndTakeDepo')
AddEventHandler('fish:checkAndTakeDepo', function()
local _source = source
local xPlayer  = QBCore.Functions.GetPlayer(_source)
    xPlayer.removeMoney(500)
end)

RegisterServerEvent('fish:returnDepo')
AddEventHandler('fish:returnDepo', function()
    local _source = source
    local xPlayer  = QBCore.Functions.GetPlayer(_source)
    local ped = GetPlayerPed(_source)
    local pedLocation = GetEntityCoords(ped)
    if someCheck[xPlayer.citizenid] then
        someCheck[xPlayer.citizenid] = false
        if #(vector3(3865.944, 4463.568, 2.73844) - pedLocation) <= 20.0 or #(vector3(-3424.41, 982.81, 8.43) - pedLocation) <= 20.0 or #(vector3(1302.839, 4225.832, 33.9087) - pedLocation) <= 20.0 then
            xPlayer.addMoney(500, "Job Payment", "Fish Job", 'returning a rented boat.')
        else
            TriggerEvent('logger:log', 'Possible Hack Attempt', xPlayer.getLegalName() .. ' attempted to receive money from the fishing job. Wrong location', _source, 'Hack', 'Hack', 1, 'Fish Job')
        end
    else
        TriggerEvent('logger:log', 'Possible Hack Attempt', xPlayer.getLegalName() .. ' attempted to receive money from the fishing job. Did not do the fish check or does not have proper fish amount', _source, 'Hack', 'Hack', 1, 'Fish Job')
    end
end)

local lootTable = {
    ["nothing"] = {225, {}},
    ["plasticbottle"] = {300, {[1] = 115, [2] = 55, [3] = 25, [4] = 5}},
    ["psp"] = {60, {[1] = 90, [2] = 10}},
    ["boomerphone"] = {60, {[1] = 90, [2] = 10}},
    ["casiowatch"] = {90, {[1] = 90, [2] = 30, [3] = 10}},
    ["gameman"] = {60, {[1] = 90, [2] = 10}},
    ["fruitphone"] = {60, {[1] = 90, [2] = 10}},
    ["nokia"] = {60, {[1] = 90, [2] = 10}},
    ["pixel"] = {60, {[1] = 90, [2] = 10}},
    ["samsung"] = {60, {[1] = 90, [2] = 10}},
    ["boombox"] = {45, {[1] = 90, [2] = 10}},
    ["pepperonipizzac"] = {15, {[1] = 100}},
    ["weapon_pistol"] = {1, {[1] = 100}},
}

RegisterServerEvent('erp-fish:getFish')
AddEventHandler('erp-fish:getFish', function(bait, multiplier, zone, location, boostTime)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local fishName = ''
    if zone then
        if bait == 'fishbait' then
            local rdn = exports['qb-core']:qbRandomNumber(1,100)
            if rdn <= 33 then
                fishName = 'fish'
            elseif rdn > 33 and rdn <= 66 then
                fishName = 'fish1'
            elseif rdn > 66 then
                fishName = 'fish2'
            end
        elseif bait == 'turtlebait' then
            local rdn = exports['qb-core']:qbRandomNumber(1,100)
            if rdn <= 25 then
                fishName = 'turtle'
            elseif rdn >= 11 then
                fishName = 'fish'
            end
        end
    else
        if bait == "fishbait" then
            local rdn = exports['qb-core']:qbRandomNumber(1,100)
            if rdn <= 16 then
                fishName = 'bluegill'
            elseif rdn > 16 and rdn <= 32 then
                fishName = 'redtail'
            elseif rdn > 32 and rdn <= 48 then
                fishName = 'walleye'
            elseif rdn > 48 and rdn <= 64 then
                fishName = 'perch'
            elseif rdn > 64 and rdn <= 80 then
                fishName = 'largemouth'
            elseif rdn > 80 and rdn <= 96 then
                fishName = 'tilapia'
            else
                fishName = 'clown_fish'
            end
            rnd = exports['qb-core']:qbRandomNumber(1, 100)
        elseif bait == 'turtlebait' then
            local rdn = exports['qb-core']:qbRandomNumber(1,100)
            if rdn <= 25 then
                fishName = 'turtle'
            elseif rdn >= 11 then
                fishName = 'fish'
            end
        end
    end
	local chance = 5
    if (multiplier > 0) then
        chance = 10
    end
    if boostTime > 0 then
        if (multiplier > 0) then
            multiplier = multiplier + exports['qb-core']:qbRandomNumber(1, 2)
        else
            multiplier = 1
        end
        chance = chance + 10
        TriggerClientEvent('QBCore:Notify', _source, 'You have ' .. math.floor(boostTime / 1000 + 0.5) .. "s left to your boost", "primary")
    end
    print(fishName)
    xPlayer.Functions.AddItem(fishName, 1 + multiplier, false, {}, true)
    xPlayer.Functions.AddJobReputation(1, "fish")
    TriggerEvent('erp-dailies-server:handleDailyEvent', fishName, 1 + multiplier, location, 10055, _source)
    TriggerEvent('erp-dailies-server:handleDailyEvent', "anyfish", 1 + multiplier, location, 10056, _source)
    if exports['qb-core']:qbRandomNumber(1, 100) <= (chance) then
        
        local rewardTable = {}
        local itemsFound = false
        local weight = 0
        for _, data in pairs(lootTable) do
            weight += data[1]
        end
        choice = exports["qb-core"]:qbRandomNumber(0, weight)
        weight = 0
        for item, data in pairs(lootTable) do
            if choice > weight and choice <= (weight +  data[1]) then
                if item ~= "nothing" then
                    local weightAmount = 0
                    for _, dataAmount in pairs(lootTable[item][2]) do
                        weightAmount += dataAmount
                    end
                    local choiceAmount = exports["qb-core"]:qbRandomNumber(0, weightAmount)
                    weightAmount = 0
                    for amount, dataAmount in pairs(lootTable[item][2]) do
                        if choiceAmount > weightAmount and choiceAmount <= (weightAmount +  dataAmount) then
                            if rewardTable[item] == nil then
                                rewardTable[item] = amount
                            else
                                rewardTable[item] += amount
                            end
                            break
                        end
                        weightAmount += dataAmount
                    end
                    itemsFound = true
                end
                break
            end
            weight += data[1]
        end
        for item, amount in pairs(rewardTable) do
            Player.Functions.AddItem(item, amount, false, {}, true)
        end
	end
end)