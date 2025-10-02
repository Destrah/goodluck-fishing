local QBCore = exports['qb-core']:GetCoreObject()

local fishData = {}

local minSharkDepth = 0.0
local minTurtleDepth = 0.0

local fishLabels = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        local items = exports.ox_inventory:Items()
        Wait(200)
        for types, fishList in pairs(Config.FishInfo) do
            for fishName, fishInfo in pairs(fishList) do
                if fishData[types] == nil then
                    fishData[types] = {}
                end
                if types == "shark" then
                    if fishInfo.minCatchDepth > minSharkDepth then
                        minSharkDepth = fishInfo.minCatchDepth
                    end
                elseif types == "turtle" then
                    if fishInfo.minCatchDepth > minTurtleDepth then
                        minTurtleDepth = fishInfo.minCatchDepth
                    end
                end
                fishLabels[fishName] = items[fishName].label
                table.insert(fishData[types], fishName)
            end
        end
    end
 end)

RegisterServerEvent('fish:checkAndTakeDepo')
AddEventHandler('fish:checkAndTakeDepo', function()
local _source = source
local xPlayer  = QBCore.Functions.GetPlayer(_source)
    xPlayer.removeMoney(500)
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

local function GetWeight(fish, type, depth)
    local random = exports['rush-fishing']:RandomNumber(1,100)
    local bottomSplit = Config.FishInfo[type][fish].avgWeight - (Config.FishInfo[type][fish].avgWeight / 2)
    local topSplit = Config.FishInfo[type][fish].avgWeight + (Config.FishInfo[type][fish].avgWeight / 2)
    if bottomSplit < Config.FishInfo[type][fish].minWeight then
        bottomSplit = Config.FishInfo[type][fish].minWeight
        topSplit = Config.FishInfo[type][fish].avgWeight + (Config.FishInfo[type][fish].avgWeight - bottomSplit)
    end
    if topSplit > Config.FishInfo[type][fish].maxWeight then
        topSplit = Config.FishInfo[type][fish].maxWeight
        bottomSplit = Config.FishInfo[type][fish].avgWeight - (topSplit - Config.FishInfo[type][fish].avgWeight)
    end
    local maxDepth = 290.0
    if type == "fresh" then
        maxDepth = 40.0
    end
    local skew = (maxDepth - depth) / (maxDepth - Config.FishInfo[type][fish].minCatchDepth)
    if skew < 0.1 then
        skew = 0.1
    end
    local depthAdjuster = 1 - skew
    if random <= 70 then
        return exports['rush-fishing']:NormalDist(bottomSplit, topSplit, skew, 2)
    elseif random > 70 and random <= 82 then
        return exports['rush-fishing']:RandomNumber(Config.FishInfo[type][fish].minWeight, topSplit + (depthAdjuster * (Config.FishInfo[type][fish].maxWeight - topSplit)), 2)
    else
        return exports['rush-fishing']:RandomNumber(bottomSplit + (depthAdjuster * (Config.FishInfo[type][fish].avgWeight - bottomSplit)), Config.FishInfo[type][fish].maxWeight, 2)
    end
end

local evmeta = {
    {field = 'fishWeight', label = 'Weight'},
}

local function OxMetadata(metadata)
    local description = nil

    local newmeta = {}

    for i = 1, #evmeta do
        if metadata[evmeta[i].field] then
            if description then
                description = ('%s  \n%s%s'):format(description, evmeta[i].label and ('**%s:** '):format(evmeta[i].label) or '', metadata[evmeta[i].field])
            else
                description = ('%s%s'):format(evmeta[i].label and ('**%s:** '):format(evmeta[i].label) or '', metadata[evmeta[i].field])
            end
        end
    end
    
    metadata.evtype = metadata.type
    metadata.type = nil
    metadata.description = description

    return metadata
end

RegisterCommand("testFish", function(source, args, rawCommand)
    if source == 0 then
        local fishCount = tonumber(args[3]) -- Possible amount to catch in 5 minutes
        local depth = tonumber(args[2])
        local totalTests = tonumber(args[4])
        local maxDepth = depth
        local lowest = 9999
        local highest = 0
        local fishTestType = args[1]
        local totalCash = 0.0
        local totalWeight = 0.0
        local rareCount = 0
        local bait = 'salt_fishbait'
        if fishTestType == 'fresh' then
            bait = "fresh_fishbait"
        elseif fishTestType == "turtle" then
            bait = "turtle_bait"
        elseif fishTestType == "shark" then
            bait = "shark_bait"
        end
        local totalCashFromAll = 0.0
        for j = 1, totalTests, 1 do
            totalCash = 0.0
            for i = 1, fishCount, 1 do
                local weight = 0.0
                local fishName = ""
                local fishType = ""
                fishName, fishType = GetFish(depth, maxDepth, {bait = bait}, fishType)
                weight = GetWeight(fishName, fishType, maxDepth)
                totalCash += weight * Config.FishInfo[fishType][fishName].pricePerPound
                totalCashFromAll += weight * Config.FishInfo[fishType][fishName].pricePerPound
                totalWeight += weight
            end
            print(totalCash)
        end
        print("Total average", (totalCashFromAll / totalTests))
    end
end)

local fishTypeByBait = {
    salt_fishbait = {
        default = "salt",
        fishType = "salt",
        fishTypeRare = "rare_salt",
        rareChance = 4
    },
    fresh_fishbait = {
        default = "fresh",
        fishType = "fresh",
        fishTypeRare = "rare_fresh",
        rareChance = 4
    },
    shark_bait = {
        default = "shark",
        rare = "rare_shark",
        fishType = "salt",
        fishTypeRare = "rare_salt",
        rareChance = 10
    },
    turtle_bait = {
        default = "turtle",
        rare = "rare_turtle",
        fishType = "salt",
        fishTypeRare = "rare_salt",
        rareChance = 10
    }
}

trackedFish = {}

lib.callback.register('rush-fishing-sv:GetFish', function(source, data)
    local fish, fishType = GetFish(data.depth, data.maxDepth, data.rodMeta, data.fishType)
    trackedFish[source] = {fish, fishType}
    return fish, fishType
end)

function generatePlate()
    local plate = QBCore.Shared.RandomInt(1)..QBCore.Shared.RandomStr(2)..QBCore.Shared.RandomInt(3)..QBCore.Shared.RandomStr(2)
    local result = exports.oxmysql:scalar_async('SELECT plate FROM player_vehicles WHERE plate = ? OR fakeplate = ?', {plate, plate})
    if result then
        return generatePlate()
    else
        return plate:upper()
    end
end

lib.callback.register('rush-fishing:server:rentBoat', function(source, model, price, spawnCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local money = exports['brazzers-lib']:findChargeableCurrencyType(price, Player.PlayerData.money.cash, Player.PlayerData.money.bank)
    if not money then return TriggerClientEvent("QBCore:Notify", src, 'Not enough money', "error") end    
    Player.Functions.RemoveMoney(money, price)

    local CreateAutomobile = joaat('CREATE_AUTOMOBILE')
    local car = Citizen.InvokeNative(CreateAutomobile, joaat(model), spawnCoords, true, false)

    while not DoesEntityExist(car) do
        Wait(25)
    end
    
    local NetID = NetworkGetNetworkIdFromEntity(car)
    local plate = generatePlate()
    SetVehicleNumberPlateText(car, plate)

    return true, NetID, plate
end)

function GetAllFishForDepth(depth, fishType)
    local possibleFish = {}
    for fish, fishInfo in pairs(Config.FishInfo[fishType]) do
        if depth >= fishInfo.minCatchDepth then
            table.insert(possibleFish, fish)
        end
    end
    return possibleFish
end

function GetFish(depth, maxDepth, rodMeta, fishType)
    local rareChance = exports['rush-fishing']:RandomNumber(1,100)
    local fishName = ""
    local gotFish = false
    local bait = rodMeta.bait
    if bait == "shark_bait" then
        local rdn = exports['rush-fishing']:RandomNumber(1,100)
        if rdn <= 48 and maxDepth >= minSharkDepth then
            fishType = fishTypeByBait[bait].default
            local possibleFish = GetAllFishForDepth(maxDepth, fishType)
            rdn = exports['rush-fishing']:RandomNumber(1,#possibleFish)
            fishName = possibleFish[rdn]
            gotFish = true
        end
    elseif bait == "turtle_bait" then
        local rdn = exports['rush-fishing']:RandomNumber(1,100)
        if rdn <= 48 and maxDepth >= minTurtleDepth then
            fishType = fishTypeByBait[bait].default
            local possibleFish = GetAllFishForDepth(maxDepth, fishType)
            rdn = exports['rush-fishing']:RandomNumber(1,#possibleFish)
            fishName = possibleFish[rdn]
            gotFish = true
        end
    end
    if not gotFish then
        if rareChance <= fishTypeByBait[bait].rareChance then
            fishType = fishTypeByBait[bait].fishTypeRare
            if fishData[fishType] == nil then
                fishType = fishTypeByBait[bait].fishType
            end
            local possibleFish = GetAllFishForDepth(maxDepth, fishType)
            if #possibleFish > 0 then
                rdn = exports['rush-fishing']:RandomNumber(1,#possibleFish)
                fishName = possibleFish[rdn]
            else
                fishType = fishTypeByBait[bait].fishType
                local possibleFish = GetAllFishForDepth(maxDepth, fishType)
                rdn = exports['rush-fishing']:RandomNumber(1,#possibleFish)
                fishName = possibleFish[rdn]
            end
        else
            fishType = fishTypeByBait[bait].fishType
            local possibleFish = GetAllFishForDepth(maxDepth, fishType)
            rdn = exports['rush-fishing']:RandomNumber(1,#possibleFish)
            fishName = possibleFish[rdn]
        end
    end
    return fishName, fishType
end

RegisterServerEvent('rush-fish:getFish')
AddEventHandler('rush-fish:getFish', function(multiplier, zone, location, depth, rodMeta)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local fishName = trackedFish[_source][1]
    local fishType = trackedFish[_source][2]
    local currentDepth = depth
    local weight = 0
    local maxDepth = depth
    if rodMeta.maxDepth < maxDepth then
        maxDepth = rodMeta.maxDepth
    end
    --fishName, fishType = GetFish(depth, maxDepth, rodMeta, fishType)
    weight = GetWeight(fishName, fishType, maxDepth)
	local chance = 5
    if (multiplier > 0) then
        chance = 10
    end
    TriggerClientEvent('ox_lib:notify', _source, {description = 'You caught a '..weight..' lbs '..fishLabels[fishName]..'!', type = "inform"})
    xPlayer.Functions.AddItem(fishName, 1, false, OxMetadata({fishWeight = weight}))
    
    local tournament = exports['brazzers-jobs']:tournaments()
    tournament.addScore(source, 'fishing', weight)
    exports['brazzers-jobs']:addRep(_source, 'fishing', 1)
    trackedFish[_source] = nil

    local chance = math.random(1, 100)

	if chance <= 3 then
		exports.ox_inventory:AddItem(source, 'fishingchest', 1)
		exports['brazzers-logs']:addLog('job', 'Fishing', 'Received a treasure chest', 15105570, source)
	end
end)

RegisterNetEvent("brazzers-fishing:AddTreasureItems", function()
	local chance = math.random(1, 100)
	local remove = exports.ox_inventory:RemoveItem(source, 'fishingchest', 1)
	if not remove then return end

	for i = 1, 2 do -- Receive 2 Items
		local Items = Config.treasureItems[math.random(1, #Config.treasureItems)]
		exports.ox_inventory:AddItem(source, Items, 1)
		exports['brazzers-logs']:addLog('item', 'Fishing Chest', 'Opened a treasure chest and received 1 '..Items, 15105570, source)
	end

	for i = 1, 1 do -- Cash
		local ItemsPlus = Config.treasureItemsPlus[math.random(1, #Config.treasureItemsPlus)]
		local ItemPlusAmount = math.random(9, 12)
		exports.ox_inventory:AddItem(source, ItemsPlus, ItemPlusAmount)
		exports['brazzers-logs']:addLog('item', 'Fishing Chest', 'MF got lucky and received '..ItemPlusAmount..' after opening a treasure chest', 15105570, source)
	end

	if chance <= 2 then
		exports.ox_inventory:AddItem(source, 'fishinghook', 1)
	end

    exports['brazzers-crafting']:giveBlueprint(source, 7, 1, {'items', 'melee', 'attachments'})
end)

RegisterNetEvent('rush-fishing-sv:SellFish', function(fishInfo, allFish)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
	if not Player then return end

	local cid = Player.PlayerData.citizenid

	local playerPed = GetPlayerPed(_source)
	local playerCoords = GetEntityCoords(playerPed)
	if #(playerCoords - vector3(-643.25, -1228.02, 11.55)) > 3.0 and #(playerCoords - vector3(-178.67, 314.27, 97.97)) > 3.0 and #(playerCoords - vector3(3463.7185, 3650.4756, 44.7659)) > 3.0 then
		exports['brazzers-logs']:addLog('injector', 'Fishing Rewards', 'Injected on fishing seller and was dropped from the server', 3447003, _source)
		return DropPlayer(_source, "Attempted exploit abuse")
	end

	local totalAmount = 0
	local salesLog = ""

    if allFish then
        local inventory = exports.ox_inventory:GetInventory(_source)
        for i = 1, #fishInfo, 1 do
            local success = exports.ox_inventory:RemoveItem(_source, fishInfo[i][1], fishInfo[i][6], nil, fishInfo[i][3])
            if success then
                local amount = (Config.FishInfo[fishInfo[i][5]][fishInfo[i][1]].pricePerPound * tonumber(fishInfo[i][4].fishWeight)) * fishInfo[i][6]
                if exports['rush-buffs']:HasBuff(cid, 'luck') then
                    amount = math.ceil(amount + (amount * (10 / 100)))
                end
                totalAmount = totalAmount + amount
                salesLog = salesLog .. "Sold " .. 1 .. " [" .. fishInfo[i][1] .. " (" .. fishInfo[i][4].fishWeight .. " lbs)] for $" .. amount .. "\n"
            end
        end
    else
        local inventory = exports.ox_inventory:GetInventory(_source)
        local success = exports.ox_inventory:RemoveItem(_source, fishInfo[1], fishInfo[6], nil, fishInfo[3])
        if success then
            local amount = (Config.FishInfo[fishInfo[5]][fishInfo[1]].pricePerPound * tonumber(fishInfo[4].fishWeight)) * fishInfo[6]
            if exports['rush-buffs']:HasBuff(cid, 'luck') then
                amount = math.ceil(amount + (amount * (10 / 100)))
            end
            totalAmount = totalAmount + amount
            salesLog = salesLog .. "Sold " .. 1 .. " [" .. fishInfo[1] .. "] for $" .. amount .. "\n"
        end
    end

	if totalAmount > 0 then
		Player.Functions.AddMoney('cash', math.floor((totalAmount + 0.5)))
		exports['brazzers-logs']:addLog('job', 'Fishing', salesLog .. "Total received: $" .. totalAmount, 15105570, source)
	end
end)

local evmeta = {
    {field = 'bait', label = 'Bait',},
    {field = 'line', label = 'Line',},
    {field = 'maxDepth', label = 'Max Depth',},
    {field = 'reinforced', label = 'Reinforced',},
    {field = 'length', label = 'Remaining Line Length',},
}

local function OxDescription(metafilter, metadata)
    local description = nil

    local newmeta = {}

    for i = 1, #metafilter do
        if metadata[metafilter[i].field] then
            if description then
                description = ('%s  \n%s%s'):format(description, metafilter[i].label and ('**%s:** '):format(metafilter[i].label) or '', metadata[metafilter[i].field])
            else
                description = ('%s%s'):format(metafilter[i].label and ('**%s:** '):format(metafilter[i].label) or '', metadata[metafilter[i].field])
            end
        end
    end

    return description
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

RegisterNetEvent("rush-fishing-sv:PlaceFishingBait", function(slot, baitInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local inventory = exports.ox_inventory:GetInventory(src)
    local rod = inventory.items[slot]
    local rodMeta = rod.metadata
    if not Player then return end
    if rodMeta.line then
        if rodMeta.lineLength > 0 then
            if has_value(Config.BaitInfo[baitInfo.name].validLines, rodMeta.line) then
                local success = exports.ox_inventory:RemoveItem(src, baitInfo.name, 1)
                if success then
                    if rodMeta.bait ~= 'none' and rodMeta.bait ~= nil then
                        Player.Functions.AddItem(rodMeta.bait, 1)
                    end
                    rodMeta.bait = baitInfo.name
                    rodMeta.baitLabel = baitInfo.label
                    rodMeta.description = OxDescription(evmeta, {
                        bait = baitInfo.label,
                        line = rodMeta.lineLabel,
                        maxDepth = rodMeta.maxDepth .. "m",
                        reinforced = tostring(rodMeta.reinforced):sub(1,1):upper()..tostring(rodMeta.reinforced):sub(2),
                        length = rodMeta.lineLength .. "m"
                    })
                    exports.ox_inventory:SetMetadata(src, slot, rodMeta)
                    TriggerClientEvent('ox_lib:notify', src, {description = 'Placed '..baitInfo.label..' on the fishing rod in slot '..slot, type = "inform"})
                else
                    TriggerClientEvent('ox_lib:notify', src, {description = "Failed placing fishing bait", type = "error"})
                end
            else
                TriggerClientEvent('ox_lib:notify', src, {description = "Cannot place that bait on that fishing line", type = "error"})
            end
        else 
            TriggerClientEvent('ox_lib:notify', src, {description = "The rod does not have any line on it. Please place line on it before putting bait on.", type = "error"})
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {description = "The rod does not have any line on it. Please place line on it before putting bait on.", type = "error"})
    end
end)

RegisterNetEvent("rush-fishing-sv:PlaceFishingLine", function(slot, lineInfo, placeBaitNext)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local inventory = exports.ox_inventory:GetInventory(src)
    local rod = inventory.items[slot]
    local rodMeta = rod.metadata
    if not Player then return end
    local maxDepth = 15.0
    local reinforced = false
    local lineLength = 150
    if lineInfo.name == "adv_fishingline" then
        maxDepth = 40.0
    elseif lineInfo.name == "pro_fishingline" then
        maxDepth = 125.0
    elseif lineInfo.name == "master_fishingline" then
        maxDepth = 300.0
    elseif lineInfo.name == "illegal_fishingline" then
        maxDepth = 300.0
        reinforced = true
    end
    local success = exports.ox_inventory:RemoveItem(src, lineInfo.name, 1)
    if success then
        if rod.metadata.bait ~= 'none' and rod.metadata.bait ~= nil then
            rodMeta.bait = 'none'
            Player.Functions.AddItem(rod.metadata.bait, 1)
        end
        rodMeta.line = lineInfo.name
        rodMeta.lineLabel = lineInfo.label
        rodMeta.maxDepth = maxDepth
        rodMeta.reinforced = reinforced
        rodMeta.lineLength = lineLength
        rodMeta.description = OxDescription(evmeta, {
            bait = rodMeta.baitLlabel,
            line = lineInfo.label,
            maxDepth = maxDepth .. "m",
            reinforced = tostring(reinforced):sub(1,1):upper()..tostring(reinforced):sub(2),
            length = lineLength .. "m"
        })
        exports.ox_inventory:SetMetadata(src, slot, rodMeta)
        TriggerClientEvent('ox_lib:notify', src, {description = 'Placed '..lineInfo.label..' on the fishing rod in slot '..slot, type = "inform"})
        if placeBaitNext then
            TriggerClientEvent('rush-fishing-cl:PlaceBait', src, rod)
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {description = 'Failed placing fishing line', type = "error"})
    end
end)

RegisterNetEvent("rush-fishing-sv:TakeBait", function(lineLength, rodSlot, info, contFishing)
    local _source = source
    local inventory = exports.ox_inventory:GetInventory(_source)
    local rod = inventory.items[rodSlot]
    local rodMeta = rod.metadata
    rodMeta.lineLength -= lineLength
    if rodMeta.lineLength < 0 then
        rodMeta.lineLength = 0
    end
    rodMeta.bait = "none"
    rodMeta.description = OxDescription(evmeta, {
        bait = "None",
        line = exports.ox_inventory:Items()[rodMeta.line].label,
        maxDepth = rodMeta.maxDepth .. "m",
        reinforced = tostring(rodMeta.reinforced):sub(1,1):upper()..tostring(rodMeta.reinforced):sub(2),
        length = rodMeta.lineLength .. "m"
    })
    exports.ox_inventory:SetMetadata(_source, rodSlot, rodMeta)
    if contFishing then
        TriggerClientEvent("rush-fishing-cl:RepeatFishing", _source, info, rodMeta)
    end
end)

local swap_fish_cooler = exports.ox_inventory:registerHook('swapItems', function(payload)
    if string.find(payload.fromSlot.name, "fish_") ~= 1 and payload.fromSlot.name ~= 'turtle' then
        return false
    end
end, {
    inventoryFilter = {
        '^fish_cooler_[%w]'
    }
})

CreateThread(function()
    local tournament = exports['brazzers-jobs']:tournaments()
    while not tournament do
        Wait(100) 
        tournament = exports['brazzers-jobs']:tournaments()
    end
    tournament.startTournament('Fishing Tournament', 'fishing', (60000 * 30))
end)