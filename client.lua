local QBCore = exports['qb-core']:GetCoreObject()
local initialized = false

local dialogue = {}

local isDoingMiniGame = false
local miniGameCancelled = false
local miniGameFailed = false

local blips = {
    {title="Rooster Rest", colour=48, id=206, scale=0.6, x = -178.67, y = 314.27, z = 97.97},
    {title="S. Ho Fresh Water Sushi", colour=48, id=120, scale=0.6, x = -643.25, y = -1228.02, z = 11.55}
}

Citizen.CreateThread(function()
    while QBCore == nil do
        QBCore = exports['qb-core']:GetCoreObject()
        Citizen.Wait(0)
    end
end)

Brazzers = exports['brazzers-lib']:getLib()

local fishingRodSlot = -1
local isFishing = false
local inZone = false
local cancel = false
local veh = 0
local canSpawn = true
local fishingPOS = nil
local sellingFish = false
local depth = 0
local zones = {
    'OCEANA',
    'ELYSIAN',
    'CYPRE',
    'DELSOL',
    'LAGO',
    'NCHU',
    'PALCOV',
    'PALETO',
    'PROCOB',
    'ELGORL',
    'SANCHIA',
    'PALHIGH',
    'DELBE',
    'PBLUFF',
    'GRAPES',
}
local doingSkillCheck = false
local model = nil

-- local fish = {
--     salt = {},
--     fresh = {}
-- }

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local fishInfo = {}

local function SellFishMenu(sellerLabel, fishType)
    local myItems = exports.ox_inventory:GetPlayerItems()
    local availableFish = {}
    local totalWeight = 0.0
    for id, data in pairs(myItems) do
        if (fishInfo[data.name] and has_value(fishType, (fishInfo[data.name].type:gsub("rare_", "")))) then
            if data.metadata.fishWeight == nil then
                for i = 1, #fishType, 1 do
                    if Config.FishInfo[fishType[i]][data.name] ~= nil then
                        data.metadata.fishWeight = Config.FishInfo[fishType[i]][data.name].avgWeight
                    end
                end
            end
            totalWeight += tonumber(data.metadata.fishWeight) * data.count
            table.insert(availableFish, {data.name, data.label, data.slot, data.metadata, fishInfo[data.name].type, data.count})
        end
    end
    local menu = {}

	menu[#menu+1] = {
		title = "Select a fish to sell",
		description = "Select a fish or all fish you are carrying to sell. Total weight on you is "..totalWeight.." lbs",
		icon = "fa-solid fa-info-circle",
        readOnly = true
	}

    menu[#menu+1] = {
        title = "Sell All Fish",
        description = "Click this to sell all the fish in your inventory",
        icon = "fa-solid fa-infinity",
        onSelect = function()
            TriggerServerEvent("rush-fishing-sv:SellFish", availableFish, true)
        end,
    }

    for i = 1, #availableFish, 1 do
        local description = "Weight:" .. availableFish[i][4].fishWeight * availableFish[i][6] .. "\nSlot:" .. availableFish[i][3] .. "\nCount:" .. availableFish[i][6] 
        local icon = ""
        if availableFish[i][5] == "fresh" then
            icon = "fish"
        else
            icon = "fish-fins"
        end
        menu[#menu+1] = {
            title = availableFish[i][2],
            description = description,
            icon = "fa-solid fa-"..icon,
            onSelect = function()
                TriggerServerEvent("rush-fishing-sv:SellFish", availableFish[i], false)
            end,
        }
    end

	lib.registerContext({
        id = 'fish_information',
        icon = 'fa-solid fa-receipt',
        title = sellerLabel,
        options = menu,
        canClose = true,
    })
    lib.showContext('fish_information')
end

local function Initialize()
    if initialized then return end
    initialized = true
    --fish["salt"] = {}
    --fish["fresh"] = {}
    for types, fishList in pairs(Config.FishInfo) do
        for fishName, fishData in pairs(fishList) do
            fishInfo[fishName] = {
                type = types,
                weight = fishData.minWeight
            }
        end
    end

    
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, info.scale)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end

    Brazzers.addPed({ 
        model = `u_m_y_caleb`,
        dist = 300,
        coords = vec3(-803.48, -1495.82, 1.6),
        heading = 291.84,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers_fishing_rental',
        target = {
            {
                name = 'fishing_rental',
                icon = 'fa-solid fa-ship',
                label = 'Rent Boat',
                id = 'fishing_rental',
                onSelect = function()
                    boatRental(vector4(-796.2, -1501.74, 0.12, 110.77))
                end,
                canInteract = function(_, distance)
                    if distance > 2.0 then return end
                    return true
                end,
            },
        }
    })

    Brazzers.addPed({ 
        model = `u_m_y_caleb`,
        dist = 300,
        coords = vec3(1529.6818, 3778.7747, 34.5116),
        heading = 215.7920,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers_fishing_rental',
        target = {
            {
                name = 'fishing_rental',
                icon = 'fa-solid fa-ship',
                label = 'Rent Boat',
                id = 'fishing_rental',
                onSelect = function()
                    boatRental(vector4(1522.2921, 3823.9480, 30.3257, 38.6403))
                end,
                canInteract = function(_, distance)
                    if distance > 2.0 then return end
                    return true
                end,
            },
        }
    })

    Brazzers.addPed({ 
        model = `a_m_m_tennis_01`,
        dist = 300,
        coords = vec3(-335.57, 6105.93, 31.45),
        heading = 226.36,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers-fishing-ped',
        target = {
            {
                name = 'dialogue-ped',
                icon = 'fa-regular fa-comment',
                label = 'Talk',
                id = 'dialogue-ped',
                onSelect = function(entityTable)
                    dialogue.openDialog(entityTable.entity)
                end,
            },
            {
                name = 'tournament_join',
                icon = 'fa-solid fa-right-from-bracket',
                label = 'Join Tournament',
                id = 'tournament_join',
                onSelect = function()
                    local tournament = exports['brazzers-jobs']:tournaments()
                    tournament.joinTournament('fishing')
                end,
                canInteract = function(_, distance)
                    local tournament = exports['brazzers-jobs']:tournaments()
                    if tournament.inTournament('fishing') then return end
                    if not tournament.current['fishing'].active then return end
                    return true
                end,
            },
            {
                name = 'tournament_leave',
                icon = 'fa-solid fa-right-from-bracket',
                label = 'Leave Tournament',
                id = 'tournament_leave',
                onSelect = function()
                    local tournament = exports['brazzers-jobs']:tournaments()
                    tournament.leaveTournament('fishing')
                end,
                canInteract = function(_, distance)
                    local tournament = exports['brazzers-jobs']:tournaments()
                    if not tournament.inTournament('fishing') then return end
                    if not tournament.current['fishing'].active then return end
                    return true
                end,
            },
            {
                name = 'tournament_history',
                icon = 'fa-solid fa-clock-rotate-left',
                label = 'Tournament History',
                id = 'tournament_history', 
                onSelect = function()
                    local tournament = exports['brazzers-jobs']:tournaments()
                    tournament.showLeaderboards('fishing')
                end,
                canInteract = function(_, distance)
                    local tournament = exports['brazzers-jobs']:tournaments()
                    if not tournament.history['fishing'] then return end
                    return true
                end,
            },
        },
    })

    Brazzers.addPed({ 
        model = `ig_chef`,
        dist = 300,
        coords = vec3(-642.8211, -1228.7715, 11.5483),
        heading = 359.6322,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers-fishing2-ped',
        target = {
            {
                name = 'brazzers-fishing2-ped',
                icon = 'fas fa-fish',
                label = 'Sell Fresh Water Fish',
                id = 'fishing_sellfish_fresh',
                onSelect = function() SellFishMenu("Fresh Fish Buyer", {"fresh"}) end,
                canInteract = function(_, distance)
                    if distance > 2.0 then return end
                    return true
                end,
            }
        }
    })

    Brazzers.addPed({ 
        model = `ig_chef`,
        dist = 300,
        coords = vec3(-178.67, 314.27, 97.97),
        heading = 87.8868,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers-fishing2-ped',
        target = {
            {
                name = 'brazzers-fishing2-ped',
                icon = 'fas fa-fish',
                label = 'Sell Salt Water Fish',
                id = 'fishing_sellfish_salt',
                onSelect = function() SellFishMenu("Salt Water Fish Buyer", {"salt"}) end,
                canInteract = function(_, distance)
                    if distance > 2.0 then return end
                    return true
                end,
            }
        }
    })

    Brazzers.addPed({ 
        model = `ig_chef`,
        dist = 300,
        coords = vec3(3463.7185, 3650.4756, 44.7659),
        heading = 345.7624,
        snapToGround = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        freeze = true,
        invincible = true,
        tempevents = true,
        id = 'brazzers-fishing2-ped',
        target = {
            {
                name = 'brazzers-fishing2-ped',
                icon = 'fas fa-fish',
                label = 'Sell Illicit Fish',
                id = 'fishing_sellfish_fresh',
                onSelect = function() SellFishMenu("Illicit Fish Buyer", {"turtle", "shark"}) end,
                canInteract = function(_, distance)
                    if distance > 2.0 then return end
                    return true
                end,
            }
        }
    })
end

function boatRental(spawnCoords)
    local menu = {}
    for _, v in pairs(Config.boats) do
        menu[#menu + 1] = {
            title = v.label,
            description = '$'..v.price,
            onSelect = function()
                local result, netId, plate = lib.callback.await('rush-fishing:server:rentBoat', false, v.model, v.price, spawnCoords)
                if not result then return end
                while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(100) end
                
                local vehicle = NetToVeh(netId)
                TriggerEvent('brazzers-vehiclekeys:client:setOwner', plate)
                exports['rush-fuel']:SetFuel(vehicle, 100.0)
            end,
        }
    end

    lib.registerContext({
        id = 'boatrental',
        icon = 'fa-solid fa-ship',
        title = 'Rental',
        options = menu
    })
    lib.showContext('boatrental')
end

function dialogue.talkBusiness()
    local buttons = {}

    buttons[#buttons + 1] = {
        label = 'Sign In', close = true,
        onSelect = function()
            TriggerEvent('brazzers-jobs:client:signIn', 'fishing')
        end,
        canInteract = function()
            local signedIn = exports['brazzers-jobs']:signedIn()
            if signedIn then return end
            return true
        end,
    }

    buttons[#buttons + 1] = {
        label = 'Sign Out', close = true,
        onSelect = function()
            TriggerEvent('brazzers-jobs:client:signOut', 'fishing')
        end,
        canInteract = function()
            local signedIn = exports['brazzers-jobs']:signedIn()
            if not signedIn then return end

            local group = exports['brazzers-jobs']:groups()
            local groupID = exports['brazzers-jobs']:getMyGroup()
            if groupID then
                if group[groupID].tasks.complete then return end
            end

            return true
        end,
    }

    buttons[#buttons + 1] = {
        label = 'Leave Conversation', close = true,
    }

    Brazzers.setDialogue({
        response = 'I\'ve got some, but I could always use more. What\'s next?',
        text = 'Sign in, and head over to our fishing zones. You\'ll meet some others out there with you. We also send alerts out for fishing tournaments. If you\'re interested, come back to me to get involved. We give great rewards for winners. We also give you some job offers to keep you on your toes at all times. You can view those on your phone.',
        buttons = buttons
    })
end

function dialogue.openDialog(entity)
    local data, job = {}, 'fishing'

    data.dialogue = {
        name = 'Henry Jackson',
        response = 'Hey, I\'ve always wanted to try fishing, but I\'m clueless about where to begin. Any tips for a total newbie like me?',
        text = 'You\'ll need a basic rod and reel, some luck, and patience. How\'s your patience?',
        job = 'Fishing', rep = 'fishing',
        buttons = {}
    }

    if job and job ~= 'fishing' then
        data.dialogue.text = 'Hello, welcome to Fishing Market! Please checkout of your current job before speaking with me. We\'re not looking for those employed.'
    end

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'Let\'s talk business', close = false,
        onSelect = function()
            dialogue.talkBusiness()
        end,
        canInteract = function()
            if job and job ~= 'fishing' then return end

            local group = exports['brazzers-jobs']:groups()
            local groupID = exports['brazzers-jobs']:getMyGroup()
            if group[groupID] and group[groupID].job ~= 'fishing' then return end

            return true
        end,
    }

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'Complete Job', close = true,
        onSelect = function()
            fishing.completeJob()
        end,
        canInteract = function()
            local signedIn = exports['brazzers-jobs']:signedIn()
            if not signedIn then return end

            if job and job ~= 'fishing' then return end

            local group = exports['brazzers-jobs']:groups()
            local groupID = exports['brazzers-jobs']:getMyGroup()
            if not groupID then return end

            if group[groupID].tasks and not group[groupID].tasks.complete then return end
            if not employment.isLeader() then return end

            return true
        end,
    }

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'Shop', close = true,
        onSelect = function()
            local rep = exports['brazzers-jobs']:getRep('fishing')
            local shopType = "basic"
            if rep >= 1000 and rep <= 2500 then
                shopType = "advanced"
            elseif rep > 2500 and rep <= 5000 then
                shopType = "pro"
            elseif rep > 5000 and rep < 10000 then
                shopType = "master"
            elseif rep >= 10000 then
                shopType = "master_illicit"
            end
            exports.ox_inventory:openInventory('shop', {type = 'shops_fishingstore_'..shopType})
        end,
        canInteract = function()
            return true
        end,
    }

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'Leave Conversation', close = true,
    }

    exports['brazzers-lib']:openDialogue(entity, data)
end

local function animation(ped, dict, anim, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, flag, 0, 0, 0, 0)
    RemoveAnimDict(dict)
end

local function createRod(data)
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    local RodHash = data.model
    lib.requestModel(RodHash)
    model = CreateObject(RodHash, pos, true)
    AttachEntityToEntity(model, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.05, 0, 80.0, 120.0, 160.0, true, true,
    false, true, 1, true)
    SetModelAsNoLongerNeeded(RodHash)
end

local function deleteRod()
    while DoesEntityExist(model) do
        Citizen.Wait(10)
        DeleteEntity(model)
    end
    model = nil
end

local function checks(data)
    local ped = GetPlayerPed(-1)
    if model then return lib.notify({id = "fish_wrong_bait_type", description = 'You already have a fishing rod in your hands!', duration = 7500, showDuration = true, type = "error"}) end
    if IsPedInAnyVehicle(ped, false) then return lib.notify({id = "fish_wrong_bait_type", description = 'You can\'t fish while being inside a car...', duration = 7500, showDuration = true, type = "error"}) end
    if IsPedSwimming(ped) then return lib.notify({id = "fish_wrong_bait_type", description = 'You can\'t be swimming and fishing at the same time.', duration = 7500, showDuration = true, type = "error"}) end
    
    createRod(data)

    return true
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Initialize()
    end
end)

local requiredReps = {
    ["fishingrod"] = 0,
    ["fishingrod2"] = 10000,
    ["basic_fishingline"] = 0,
    ["adv_fishingline"] = 1000,
    ["pro_fishingline"] = 2500,
    ["master_fishingline"] = 5000,
    ["illegal_fishingline"] = 10000,
    ["fresh_fishbait"] = 0,
    ["salt_fishbait"] = 2500,
    ["turtle_bait"] = 10000,
    ["shark_bait"] = 10000
}

local lineRequiresZone = {
    ["basic_fishingline"] = false,
    ["adv_fishingline"] = false,
    ["pro_fishingline"] = true,
    ["master_fishingline"] = true,
    ["illegal_fishingline"] = true,
}

local function PlaceLine(data)
    local myItems = exports.ox_inventory:GetPlayerItems()
    local fishingLines = {}
    data.label = exports.ox_inventory:Items(data.name).label
    for id, itemData in pairs(myItems) do
        if ((data.name == "fishingrod" or data.name == "fishingrod2") and (itemData.name == "basic_fishingline" or itemData.name == "adv_fishingline" or itemData.name == "pro_fishingline" or itemData.name == "master_fishingline") or (data.name == "fishingrod2" and itemData.name == "illegal_fishingline")) then
            table.insert(fishingLines, itemData)
        end
    end
    local menu = {}

	menu[#menu+1] = {
		title = "Place fishing line on a rod",
		description = "Select a fishing line to place on " .. data.label,
		icon = "fa-solid fa-info-circle",
        readOnly = true
	}

    if #fishingLines > 0 then
        for i = 1, #fishingLines, 1 do
            local description = ""
            local icon = "fish"
            menu[#menu+1] = {
                title = fishingLines[i].label .. " in slot "..fishingLines[i].slot.."",
                description = description,
                icon = "fa-solid fa-"..icon,
                onSelect = function()
                    TriggerServerEvent("rush-fishing-sv:PlaceFishingLine", data.slot, fishingLines[i], true)
                end,
            }
        end

        lib.registerContext({
            id = 'fishing_line_place',
            icon = 'fa-solid fa-receipt',
            title = 'Select fishing line to place on the rod',
            options = menu,
            canClose = true,
        })
        lib.showContext('fishing_line_place')
    else
        lib.notify({id = "fish_line_requires_zone", description = 'That rod does not have any fishing line and you don\'t have any in your pockets. Go buy some', duration = 15000, showDuration = true, type = "error"})
    end
end

local function PlaceBait(data)
    local myItems = exports.ox_inventory:GetPlayerItems()
    local fishingBaits = {}
    local fishingLine = data.metadata.line
    data.label = exports.ox_inventory:Items(data.name).label
    if fishingLine ~= nil then
        local fishingLineLength = data.metadata.lineLength
        if fishingLineLength > 0 then
            for id, itemData in pairs(myItems) do
                if ((fishingLine == "basic_fishingline" or fishingLine == "adv_fishingline") and (itemData.name == "fresh_fishbait")) or ((fishingLine == "pro_fishingline" or fishingLine == "master_fishingline" or fishingLine == "illegal_fishingline") and (itemData.name == "fresh_fishbait" or itemData.name == "salt_fishbait")) or ((fishingLine == "illegal_fishingline") and (itemData.name == "fresh_fishbait" or itemData.name == "salt_fishbait" or itemData.name == "turtle_bait" or itemData.name == "shark_bait")) then
                    table.insert(fishingBaits, itemData)
                end
            end
            local menu = {}

            menu[#menu+1] = {
                title = "Place bait on a rod",
                description = "Select a bait to place on " .. data.label,
                icon = "fa-solid fa-info-circle",
                readOnly = true
            }

            if #fishingBaits > 0 then
                for i = 1, #fishingBaits, 1 do
                    local description = ""
                    local icon = "fish"
                    menu[#menu+1] = {
                        title = fishingBaits[i].label .. " in slot "..fishingBaits[i].slot.."",
                        description = description,
                        icon = "fa-solid fa-"..icon,
                        onSelect = function()
                            TriggerServerEvent("rush-fishing-sv:PlaceFishingBait", data.slot, fishingBaits[i])
                        end,
                    }
                end

                lib.registerContext({
                    id = 'fishing_bait_place',
                    icon = 'fa-solid fa-receipt',
                    title = 'Select bait to place on the rod',
                    options = menu,
                    canClose = true,
                })
                lib.showContext('fishing_bait_place')
            else
                lib.notify({id = "fish_line_requires_zone", description = 'That rod does not have any bait and you don\'t have any in your pockets. Go buy some', duration = 15000, showDuration = true, type = "error"})
            end
        else
            lib.notify({id = "fish_line_requires_zone", description = 'You don\'t have any fishing line on the rod.', duration = 15000, showDuration = true, type = "error"})
        end
    else
        lib.notify({id = "fish_line_requires_zone", description = 'You don\'t have any fishing line on the rod.', duration = 15000, showDuration = true, type = "error"})
    end
end

RegisterNetEvent('rush-fishing-cl:PlaceBait', PlaceBait)

RegisterNetEvent('rush-fish:lego')
AddEventHandler('rush-fish:lego', function(data, slot)
    checkZone()
    if slot.metadata.line ~= nil and slot.metadata.lineLength > 0 then
        if (lineRequiresZone[slot.metadata.line] == inZone) or lineRequiresZone[slot.metadata.line] then
            local fishingRodModel = 'prop_fishing_rod_01'
            if slot.name == 'fishingrod2' then
                fishingRodModel = 'prop_fishing_rod_02'
            end
            local rep = exports['brazzers-jobs']:getRep('fishing')
            local info = { model = fishingRodModel, time = math.random(40, 60) }
            if isFishing == false then
                fishingRodSlot = slot.slot
                if requiredReps[slot.name] then
                    if requiredReps[slot.metadata.line] then
                        if requiredReps[slot.metadata.bait] then
                            if rep >= requiredReps[slot.metadata.line] and rep >= requiredReps[slot.metadata.bait] and rep >= requiredReps[slot.name] then
                                StartFish(info, slot.metadata)
                            else
                                lib.notify({id = "fish_line_length_short", description = 'You are not high enough reputation to use this rod, line and/or bait.', duration = 7500, showDuration = true, type = "error"})
                            end
                        else
                            PlaceBait(slot)
                        end
                    else
                        PlaceLine(slot)
                    end
                else
                    lib.notify({id = "fish_line_length_short", description = 'Not a valid fishing rod', duration = 7500, showDuration = true, type = "error"})
                end
            elseif isFishing == true then
                if (IsPedUsingScenario(ped, 'WORLD_HUMAN_STAND_FISHING') or doingSkillCheck or IsEntityPlayingAnim(ped, "amb@world_human_stand_fishing@idle_a", "idle_c", 3)) and DoesEntityExist(model) then
                    lib.notify({id = "fish_wrong_bait_type", description = 'You are already fishing dingus.', duration = 7500, showDuration = true, type = "error"})
                else
                    isFishing = false
                end
            end
        else
            lib.notify({id = "fish_line_requires_zone", description = 'That line is not made for salt water', duration = 7500, showDuration = true, type = "error"})
        end
    else
        PlaceLine(slot)
        --lib.notify({id = "fish_line_length_short", description = 'You need some fishing line on your rod to be able to fish', duration = 7500, showDuration = true, type = "error"})
    end
end)

function checkZone()
    local ply = PlayerPedId()
    local coords = GetEntityCoords(ply)
    local currZone = GetNameOfZone(coords)
    for k,v in pairs(zones) do
        if currZone == v then
            inZone = true
            break
        else
            inZone = false
        end
    end
end

function IsEntityRightAboveWater(entity)
    local isRightAboveWater = false
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(entity, 1)
    cancel = false
    local startZ = 0
    local stopLoop = false
    while startZ > -20 and not stopLoop do
        coordB = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, startZ)
        hit, hitPos = TestProbeAgainstAllWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 1)
        if hit == 1 then
            local bool, groundZ, normal = GetGroundZFor_3dCoord(hitPos.x, hitPos.y, hitPos.z, false)
                local vehicleCoords = GetEntityCoords(entity)
                local min, max = GetModelDimensions(GetEntityModel(entity))
                local vehHeightMin = min[3]
                local vehHeightMax = max[3]
            
                if #(hitPos - vehicleCoords) <= (math.abs(vehHeightMin) + #(coordA - vehicleCoords)) then
                    isRightAboveWater = true
                end
                stopLoop = true
            break
        end
        startZ = startZ - 0.1
    end
    return isRightAboveWater
end

local amphibiousAircraftModels = 
{
    -901163259,
    -392675425,
    273925117,
	-726768679,
	104322410
}

function IsThisModelAnAmphibiousAircraft(model)
    for i = 1, #amphibiousAircraftModels, 1 do
        if model == amphibiousAircraftModels[i] then
            return true
        end
    end
    return false
end

function GetEntityBelow()
    local Ent = nil
    local playerped = GetPlayerPed(-1)
    local CoA = GetEntityCoords(playerped, 1)
    local CoB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 0.0, -5.0)
    local RayHandle = CastRayPointToPoint(CoA.x, CoA.y, CoA.z, CoB.x, CoB.y, CoB.z, 10, playerped, 0)
    local A,B,C,D,Ent = GetRaycastResult(RayHandle)
    local model = GetEntityModel(Ent)
    if IsThisModelABoat(model) or IsThisModelAJetski(model) or IsThisModelAnAmphibiousCar(model) or IsThisModelAnAmphibiousQuadbike(model) or IsThisModelAnAmphibiousAircraft(model) then
        return Ent
    else
        return 0
    end 
end

function getDepthFromFinder()
    checkZone()
    local playerped = GetPlayerPed(-1)
    boat = GetEntityBelow()
    if (IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(playerped) == false then
        QBCore.Functions.Progressbar("rush_fishing_depthfinder", 'Getting Depth', 4000, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            lib.notify({id = "fish_wrong_bait_type", description = 'You are at a depth of ' .. getDepth(boat) .. 'm', duration = 7500, showDuration = true, type = "inform"})
        end, function()
            return nil
        end)
    else
        lib.notify({id = "fish_wrong_bait_type", description = 'You must be standing on a boat and in a fishing area to use this', duration = 7500, showDuration = true, type = "error"})
        return nil
    end
end

function getDepth(entity)
    checkZone()
    local currentDepth = 0.0
    local coordA = GetEntityCoords(entity, 1)
    cancel = false
    local startZ = 0
    local stopLoop = false
    while startZ > -20 and not stopLoop do
        coordB = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, startZ)
        hit, hitPos = TestProbeAgainstAllWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 1)
        if hit == 1 then
            local bool, groundZ, normal = GetGroundZFor_3dCoord(hitPos.x, hitPos.y, hitPos.z, false)
                if bool then
                    currentDepth = QBCore.Shared.Round((hitPos.z - groundZ), 1)
                else
                    currentDepth = 300.0
                end
                stopLoop = true
            break
        end
        startZ = startZ - 0.1
    end
    if currentDepth == 0.0 then
        currentDepth = 300.0
    end
    return currentDepth
end

function StartFish(info, rodMeta)
    local ply = PlayerPedId()
    boat = GetEntityBelow()
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(playerped, 1)
    coordA = vector3(coordA.x, coordA.y, coordA.z + 2)
    if IsPedSwimming(ply) == false then 
        local startZ = 0
        local startY = 0
        local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 11.0, 0.0)
        local depthhit, depthhitPos = false, nil
        local canFish = false
        local closeToWater = false
        local hit, hitPos = TestProbeAgainstAllWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 1)
        if hit == 1 then
            closeToWater = true
        end
        local maxLineLength = 50
        if rodMeta.lineLength < maxLineLength then
            maxLineLength = rodMeta.lineLength
        end
        while startY < maxLineLength and not closeToWater do
            while startZ > -20 and not closeToWater do
                coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ)
                hit, hitPos = TestProbeAgainstAllWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 1)
                if hit == 1 then
                    closeToWater = true
                end
                startZ = startZ - 0.5
            end
            startZ = 0
            startY = startY + 0.5
        end
        local startZ = 0
        local startY = 0.0
        depth = 0.0
        if closeToWater then
            while startY < maxLineLength do
                while startZ > -20 do
                    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ)
                    hit, hitPos = TestProbeAgainstAllWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 1)
                    if hit == 1 then
                        local offset = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ - 20)
                        local bool, groundZ, normal = GetGroundZAndNormalFor_3dCoord(hitPos.x, hitPos.y, hitPos.z)
                        if hitPos.z - groundZ >= 3.0 and bool then
                            if (hitPos.z - groundZ) > depth then
                                depth = hitPos.z - groundZ
                            end
                            canFish = true
                        end
                    end
                    startZ = startZ - 0.5
                end
                startZ = 0
                startY = startY + 0.5
            end
            if canFish then
                if exports.ox_inventory:GetItemCount("fishingrod", 1) then
                    cancel = false
                    fishingPOS = coordA
                    Fish(((IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(ply) == false), info, rodMeta)
                end
            else
                lib.notify({id = "fish_wrong_bait_type", description = 'The water isn\'t deep enough here', duration = 7500, showDuration = true, type = "error"})
            end
        else
            lib.notify({id = "fish_wrong_bait_type", description = 'You aren\'t close enough to water and/or facing the right direction', duration = 7500, showDuration = true, type = "error"})
        end
    end
end

local baitRequiresZone = {
    ["salt_fishbait"] = true,
    ["turtle_bait"] = true,
    ["shark_bait"] = true,
    ["fresh_fishbait"] = false,
}

function Fish(isOnWaterCraft, info, rodMeta)
    if cancel == false then
        if rodMeta.bait ~= "none" then
            if baitRequiresZone[rodMeta.bait] == inZone then

                TriggerEvent('brazzers-jobs:client:signIn', 'fishing')

                local tournament = exports['brazzers-jobs']:tournaments()

                if tournament.current['fishing'].active then
                    if not tournament.inTournament('fishing') then
                        tournament.joinTournament('fishing')
                    end
                end

                local ply = PlayerPedId()
                animation(GetPlayerPed(-1), "mini@tennis", "forehand_ts_md_far", 48)
                while IsEntityPlayingAnim(GetPlayerPed(-1), "mini@tennis", "forehand_ts_md_far", 3) do Wait(0) end
        
                local result = checks(info)
            
                if not result then return end

                animation(GetPlayerPed(-1), "amb@world_human_stand_fishing@idle_a", "idle_c", 11)
                SetPedCanRagdoll(GetPlayerPed(-1), false)
                --TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
                FishingCheck()
                isFishing = true
                local startTime = GetGameTimer()
                timer = exports['rush-fishing']:RandomNumber(10000, 13500)
                while cancel == false and (GetGameTimer() - startTime) < timer do
                    Citizen.Wait(1)
                end
                Catch(isOnWaterCraft, info, rodMeta)
            else
                lib.notify({id = "fish_wrong_bait_type", description = 'You are not in the correct area to use the bait type of ' .. rodMeta.bait .. '  \nUse the bait item to change it on the rod', duration = 7500, showDuration = true, type = "error"})
                isFishing = false
            end
        else
            lib.notify({id = "fish_wrong_bait_type", description = 'You don\'t have any bait on that rod', duration = 7500, showDuration = true, type = "error"})
            isFishing = false
        end
    end
end

local isChecking = false

function FishingCheck()
    if not isChecking then
        isChecking = true
        Citizen.CreateThread(function()
            local ped = GetPlayerPed(-1)
            local isOnWaterCraft = (IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(ply) == false
            while IsPedUsingScenario(ped, 'WORLD_HUMAN_STAND_FISHING') or doingSkillCheck or IsEntityPlayingAnim(ped, "amb@world_human_stand_fishing@idle_a", "idle_c", 3) do
                Citizen.Wait(250)
            end
            if isFishing then
                lib.notify({id = "fish_wrong_bait_type", description = 'You moved and stopped fishing', duration = 7500, showDuration = true, type = "error"})
                SetPedCanRagdoll(GetPlayerPed(-1), true)
                cancel = true
                deleteRod()
            end
            isFishing = false
            isChecking = false
        end)
    end
end


function Repeat(info, rodMeta)
    checkZone()
    if rodMeta.lineLength > 0 then
        local isOnWaterCraft = (IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(ply) == false
        local playerped = GetPlayerPed(-1)
        local coordA = GetEntityCoords(playerped, 1)
        if #(fishingPOS - coordA) > 3.0 and not isOnWaterCraft then
            lib.notify({id = "fish_wrong_bait_type", description = 'You stopped fishing because you moved.', duration = 7500, showDuration = true, type = "error"})
            SetPedCanRagdoll(GetPlayerPed(-1), true)
            ClearPedTasksImmediately(ply)
            cancel = true
            deleteRod()
        end
        if cancel == false then
            if rodMeta.bait ~= "none" then
                if baitRequiresZone[rodMeta.bait] == inZone then
                    Citizen.Wait(450)
                    local ply = PlayerPedId()
                    cancel = false
                    isFishing = true
                    animation(GetPlayerPed(-1), "mini@tennis", "forehand_ts_md_far", 48)
                    while IsEntityPlayingAnim(GetPlayerPed(-1), "mini@tennis", "forehand_ts_md_far", 3) do Wait(0) end
            
                    local result = checks(info)
                
                    if not result then return end

                    animation(GetPlayerPed(-1), "amb@world_human_stand_fishing@idle_a", "idle_c", 11)
                    SetPedCanRagdoll(GetPlayerPed(-1), false)
                    FishingCheck()
                    isFishing = true
                    local startTime = GetGameTimer()
                    timer = exports['rush-fishing']:RandomNumber(10000, 13500)
                    while cancel == false and (GetGameTimer() - startTime) < timer do
                        Citizen.Wait(1)
                    end
                    Catch(isOnWaterCraft, info, rodMeta)
                else
                    lib.notify({id = "fish_wrong_bait_type", description = 'You are not in the correct area to use the bait type of ' .. rodMeta.bait .. '  \nUse the bai item to switch', duration = 7500, showDuration = true, type = "error"})
                end
            else
                lib.notify({description = 'You don\'t have any bait on your fishing rod', type = "error", duration = 7500})
                isFishing = false
            end
        end
    else
        SetPedCanRagdoll(GetPlayerPed(-1), true)
        lib.notify({id = "fish_line_length_short", description = 'You need some fishing line on your rod to be able to fish', duration = 7500, showDuration = true, type = "error"})
        isFishing = false
    end
end

function Catch(isOnWaterCraft, info, rodMeta)
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(playerped, 1)
    if #(fishingPOS - coordA) > 3.0 and not isOnWaterCraft then
        cancel = true
        lib.notify({id = "fish_wrong_bait_type", description = 'You stopped fishing because you moved.', duration = 7500, showDuration = true, type = "error"})
        SetPedCanRagdoll(GetPlayerPed(-1), true)
        deleteRod()
    end
    if cancel == false then
        local ply = PlayerPedId()
        lib.notify({id = "fish_wrong_bait_type", description = 'There is a fish on the line.', duration = 7500, showDuration = true, type = "inform"})
        local catching = true

        local chance, seconds, circles = math.random(1, 100), math.random(10, 17), 1
        doingSkillCheck = true
        
        isDoingMiniGame = true
        local maxDepth = depth
        if rodMeta.maxDepth < maxDepth then
            maxDepth = rodMeta.maxDepth
        end
        local fish, fishType = lib.callback.await('rush-fishing-sv:GetFish', GetPlayerServerId(PlayerId()), {depth = depth, maxDepth = maxDepth, rodMeta = rodMeta, fishType = ''})
        local barSize = 12
        local barSpeed = 1.45
        local fishSpeed = 0.45
        local progDecRate = 0.1
        local progIncRate = 0.255
        local fishModel = 'a_c_fish'
        if fish == "turtle" then
            barSize = 10.5
            barSpeed = 1.65
            fishSpeed = 0.6
        elseif fish == "fish_shark" then
            barSize = 10.5
            barSpeed = 1.85
            fishSpeed = 0.8
            progDecRate = 0.85
            progIncRate = 0.240
            fishModel = 'a_c_sharktiger'
        end
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'start',
            barSize = barSize,
            barSpeed = barSpeed,
            fishSpeed = fishSpeed
        })
        while isDoingMiniGame do
            Citizen.Wait(1)
        end
        --exports['rush-lock']:StartLockPickCircle(circles, seconds, function(caughtFish)
            --if caughtFish then
            if not miniGameCancelled and not miniGameFailed then
                --Succeed
                local multiplier = 0
                -- if isOnWaterCraft then
                --     multiplier = multiplier + 1
                --     depth = getDepth(GetEntityBelow())
                --     multiplier = multiplier + math.floor((depth/45.0)+0.5)
                -- end
                if exports.ox_inventory:GetItemCount("fishingrod") > 0 or exports.ox_inventory:GetItemCount("fishingrod2") > 0 then
                    if rodMeta.bait ~= "none" then
                        isFishing = false
                        local rdn = exports['rush-fishing']:RandomNumber(1,100)
                        if rdn <= 1 and not rodMeta.reinforced then
                            local randomLineLength = exports['rush-fishing']:RandomNumber(5, 15)
                            lib.notify({description = 'The fish got away and took your bait along with ' .. randomLineLength .. 'm of fishing line.', type = "error", duration = 7500})
                            TriggerServerEvent("rush-fishing-sv:TakeBait", randomLineLength, fishingRodSlot, info, rodMeta, true)
                            ClearPedTasksImmediately(ply)
                            SetPedCanRagdoll(GetPlayerPed(-1), true)
                            catching = false
                            doingSkillCheck = false
                            deleteRod()
                        else
                            local ped = GetPlayerPed(-1)
                            lib.requestAnimDict('anim@heists@ornate_bank@hack', 100)
                            lib.requestModel(fishModel)
                            TaskPlayAnim(ped, "anim@heists@ornate_bank@hack", "hack_enter", 1.0, 1.0, 2575, 0, 0, 0, 0, 0)
                            Wait(800)
                            local boneIndex, bonePos = GetPedBoneIndex(ped, 0xfa70), GetWorldPositionOfEntityBone(ped, boneIndex)
                            local FishPed = CreatePed(28, GetHashKey(fishModel), bonePos.x, bonePos.y, bonePos.z, true, true, true)
                            AttachEntityToEntity(FishPed, ped, GetPedBoneIndex(ped, 57005), 0.1, 0, -0.1, -45.0, 45.0, 0.0, true, true, false, true, 1, true)

                            Wait(1750)

                            DeletePed(FishPed)
                            TriggerServerEvent('rush-fish:getFish', multiplier, inZone, GetEntityCoords(GetPlayerPed(-1), false), depth, rodMeta)
                            Citizen.Wait(100)
                            ClearPedTasksImmediately(ply)
                            SetPedCanRagdoll(GetPlayerPed(-1), true)
                            catching = false
                            doingSkillCheck = false
                            deleteRod()
                            Repeat(info, rodMeta)
                        end
                    else
                        doingSkillCheck = false
                        SetPedCanRagdoll(GetPlayerPed(-1), true)
                        catching = false
                        deleteRod()
                        lib.notify({id = "fish_wrong_bait_type", description = 'Where did your bait go? How did you manage to catch that fish without that? Cheeky bastard. Keep that in your inventory.', duration = 7500, showDuration = true, type = "error"})
                        isFishing = false
                    end
                else
                    doingSkillCheck = false
                    SetPedCanRagdoll(GetPlayerPed(-1), true)
                    catching = false
                    deleteRod()
                    lib.notify({id = "fish_wrong_bait_type", description = 'Where did your fishing rod go? How did you manage to catch that fish without one? Cheeky bastard. Keep that thing in your inventory.', duration = 7500, showDuration = true, type = "error"})
                    isFishing = false
                end
            else
                --Fail
                local rdn = exports['rush-fishing']:RandomNumber(1,100)
                local minBreak = 55
                isFishing = false
                if rodMeta.reinforced then
                    minBreak = 10
                end
                if rdn <= minBreak then
                    local randomLineLength = exports['rush-fishing']:RandomNumber(35, 65)
                    lib.notify({description = 'The fish got away and took your bait along with ' .. randomLineLength .. 'm of fishing line.', type = "error", duration = 7500})
                    TriggerServerEvent("rush-fishing-sv:TakeBait", randomLineLength, fishingRodSlot, info, rodMeta, true)
                    ClearPedTasksImmediately(ply)
                    SetPedCanRagdoll(GetPlayerPed(-1), true)
                    catching = false
                    doingSkillCheck = false
                    deleteRod()
                else
                    lib.notify({id = "fish_wrong_bait_type", description = 'The fish got away.', duration = 7500, showDuration = true, type = "error"})
                    ClearPedTasksImmediately(ply)
                    SetPedCanRagdoll(GetPlayerPed(-1), true)
                    catching = false
                    doingSkillCheck = false
                    deleteRod()
                    Repeat(info, rodMeta)
                end
            end
        --end)
        while catching do
            Citizen.Wait(50)
        end
    end
end

RegisterNetEvent("rush-fishing-cl:RepeatFishing", function(info, rodMeta)
    Repeat(info, rodMeta)
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
     
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Initialize()
end)

exports('chest', function(data, slot)
    QBCore.Functions.Progressbar("PROP_HUMAN_BUM_BIN", "Opening Chest", 10000, false, true, {
		disableMovement = false,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function()
        ClearPedTasks(cache.ped)
        TriggerServerEvent("brazzers-fishing:AddTreasureItems")
	end, function()
		ClearPedTasks(cache.ped)
	end)
end)

exports('fishbait', function(data, slot)
    local myItems = exports.ox_inventory:GetPlayerItems()
    local fishingRods = {}
    for id, itemData in pairs(myItems) do
        if ((itemData.name == "fishingrod" and (slot.name ~= "turtle_bait" and slot.name ~= "shark_bait")) or itemData.name == "fishingrod2") then
            table.insert(fishingRods, {itemData.name, itemData.label, itemData.slot})
        end
    end
    local menu = {}

	menu[#menu+1] = {
		title = "Place "..data.label.." on a rod",
		description = "Select a rod to place "..data.label.." on",
		icon = "fa-solid fa-info-circle",
        readOnly = true
	}

    for i = 1, #fishingRods, 1 do
        local description = "Select the rod in this slot (" .. fishingRods[i][3] .. ") to place " .. data.label .. " on."
        local icon = "fish"
        menu[#menu+1] = {
            title = fishingRods[i][2] .. " in slot "..fishingRods[i][3].."",
            description = description,
            icon = "fa-solid fa-"..icon,
            onSelect = function()
                TriggerServerEvent("rush-fishing-sv:PlaceFishingBait", fishingRods[i][3], data)
            end,
        }
    end

	lib.registerContext({
        id = 'fishing_bait_place',
        icon = 'fa-solid fa-receipt',
        title = 'Select rod to place bait on',
        options = menu,
        canClose = true,
    })
    lib.showContext('fishing_bait_place')
end)

exports('fishingline', function(data, slot)
    local myItems = exports.ox_inventory:GetPlayerItems()
    local fishingRods = {}
    for id, itemData in pairs(myItems) do
        if ((itemData.name == "fishingrod" and slot.name ~= "illegal_fishingline") or itemData.name == "fishingrod2") then
            table.insert(fishingRods, {itemData.name, itemData.label, itemData.slot})
        end
    end
    local menu = {}

	menu[#menu+1] = {
		title = "Place "..data.label.." on a rod",
		description = "Select a rod to place "..data.label.." on",
		icon = "fa-solid fa-info-circle",
        readOnly = true
	}

    for i = 1, #fishingRods, 1 do
        local description = "Select the rod in this slot (" .. fishingRods[i][3] .. ") to place " .. data.label .. " on."
        local icon = "fish"
        menu[#menu+1] = {
            title = fishingRods[i][2] .. " in slot "..fishingRods[i][3].."",
            description = description,
            icon = "fa-solid fa-"..icon,
            onSelect = function()
                TriggerServerEvent("rush-fishing-sv:PlaceFishingLine", fishingRods[i][3], data)
            end,
        }
    end

	lib.registerContext({
        id = 'fishingline_place',
        icon = 'fa-solid fa-receipt',
        title = 'Select rod to place fishing line on',
        options = menu,
        canClose = true,
    })
    lib.showContext('fishingline_place')
end)

exports('fish_cooler', function(data, slot)
    local metadata = slot.metadata

    if not metadata.boxid then
        local result = lib.callback.await('brazzers-consume:server:setBoxId', false, slot)
        if not result then return end
        metadata.boxid = result
    end

    local id, name, slots, weight = 'fish_cooler_'..metadata.boxid, 'Fish Cooler', 40, 100000
    if not exports.ox_inventory:openInventory('stash', id) then
        local success = lib.callback.await('brazzers-scripts:server:registerBoxes', false, id, name, slots, weight)
        if not success then return end
        exports.ox_inventory:openInventory('stash', id)
    end
end)

RegisterCommand('fishminigame', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'start',
        barSize = 10,
        barSpeed = 1.65,
        fishSpeed = 0.7
    })
end)

RegisterNUICallback('FinishMiniGame', function(data, cb)
    SetNuiFocus(false, false)
    miniGameCancelled = data.cancelled
    miniGameFailed = data.failed
    isDoingMiniGame = false
    cb('ok')
end)

exports("SellFishMenu", SellFishMenu)
exports("getDepthFromFinder", getDepthFromFinder)