local QBCore = exports['qb-core']:GetCoreObject()
Citizen.CreateThread(function()
    while QBCore == nil do
        QBCore = exports['qb-core']:GetCoreObject()
        Citizen.Wait(0)
    end
end)

local bait = "fishbait"
local isFishing = false
local inZone = false
local cancel = false
local veh = 0
local canSpawn = true
local fishingPOS = nil
local sellingFish = false
local zones = {
    'OCEANA',
    'ELYSIAN',
    'CYPRE',
    'DELSOL',
    'LAGO',
    'ZANCUDO',
    'ALAMO',
    'NCHU',
    'CCREAK',
    'PALCOV',
    'PALETO',
    'PROCOB',
    'ELGORL',
    'SANCHIA',
    'PALHIGH',
    'DELBE',
    'PBLUFF',
    'SANDY',
    'GRAPES',
}

function getWaterInDirection(coordFrom, coordTo, entity)
	local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z + 3, coordTo.x, coordTo.y, coordTo.z, 1, entity, 0)
    print(rayHandle)
	local a, b, c, d, vehicle = GetShapeTestResult(rayHandle)
    print(tostring(a),tostring(b),tostring(c),tostring(d),tostring(vehicle))
	return vehicle
end

RegisterNetEvent('erp-fish:lego')
AddEventHandler('erp-fish:lego', function()
    if isFishing == false then
        StartFish()
    elseif isFishing == true then
        QBCore.Functions.Notify('You are already fishing dingus.', "error", 7500)
    end
end)

RegisterNetEvent('erp-fish:setbait')
AddEventHandler('erp-fish:setbait', function(newbait)
    bait = newbait
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
    local coordA = GetEntityCoords(playerped, 1)
    cancel = false
    fishingPOS = coordA
    local startZ = 0
    local stopLoop = false
    while startZ > -20 and not stopLoop do
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 0.0, startZ)
        hit, hitPos = TestProbeAgainstWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z)
        if hit then
            local bool, groundZ, normal = GetGroundZFor_3dCoord(hitPos.x, hitPos.y, hitPos.z, false)
                local vehicleCoords = GetEntityCoords(boat)
                local min, max = GetModelDimensions(GetEntityModel(boat))
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

function GetEntityBelow()
    local Ent = nil
    local playerped = GetPlayerPed(-1)
    local CoA = GetEntityCoords(playerped, 1)
    local CoB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 0.0, -5.0)
    local RayHandle = CastRayPointToPoint(CoA.x, CoA.y, CoA.z, CoB.x, CoB.y, CoB.z, 10, playerped, 0)
    local A,B,C,D,Ent = GetRaycastResult(RayHandle)
    local model = GetEntityModel(Ent)
    if IsThisModelABoat(model) or IsThisModelAJetski(model) or IsThisModelAnAmphibiousCar(model) or IsThisModelAnAmphibiousQuadbike(model) or QBCore.Functions.IsThisModelAnAmphibiousAircraft(model) then
        return Ent
    else
        return 0
    end 
end

function getDepthFromFinder()
    checkZone()
    local playerped = GetPlayerPed(-1)
    boat = GetEntityBelow()
    print(boat, CanAnchorBoatHere(boat))
    print((IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) , IsPedSwimming(playerped) , inZone )
    if (IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(playerped) == false and inZone == true then
        local finished = exports["erp-taskbar"]:taskBar(4000,"Getting Depth",true,false,playerVeh)
        if finished == 100 then
            return getDepth()
        end
    else
        exports['okokNotify']:Alert("Depth Finder", "You must be standing on a boat and in a fishing area to use this", 7500, 'error')
        return nil
    end
end

function getDepth()
    checkZone()
    local playerped = GetPlayerPed(-1)
    local depth = 0.0
    local coordA = GetEntityCoords(playerped, 1)
    cancel = false
    fishingPOS = coordA
    local startZ = 0
    local stopLoop = false
    while startZ > -20 and not stopLoop do
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 0.0, startZ)
        hit, hitPos = TestProbeAgainstWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z)
        if hit then
            local bool, groundZ, normal = GetGroundZFor_3dCoord(hitPos.x, hitPos.y, hitPos.z, false)
                if bool then
                    depth = QBCore.Shared.Round((hitPos.z - groundZ), 1)
                else
                    depth = 250.0
                end
                stopLoop = true
            break
        end
        startZ = startZ - 0.1
    end
    return depth
end

function StartFish()
    local ply = PlayerPedId()
    boat = GetEntityBelow()
    checkZone()
    Citizen.Wait(250)
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(playerped, 1)
    coordA = vector3(coordA.x, coordA.y, coordA.z + 2)
    if (IsEntityInWater(boat) or IsEntityRightAboveWater(boat)) and IsPedSwimming(ply) == false and inZone == true then
        if QBCore.Functions.HasItem("fishingrod", 1) then
            cancel = false
            fishingPOS = coordA
            Fish(true)
        end
    elseif IsEntityInWater(ply) and IsPedSwimming(ply) == false and inZone == true then 
        if QBCore.Functions.HasItem("fishingrod", 1) then
            cancel = false
            fishingPOS = coordA
            Fish(false)
        end
    elseif IsPedSwimming(ply) == false then 
        local startZ = 0
        local startY = 0
        local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 50.0, -15.0)
        local hit, hitPos = TestProbeAgainstWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z)

        local depthhit, depthhitPos = false, nil
        local canFish = false
        local closeToWater = false
        while startY < 11 and not closeToWater do
            while startZ > -20 and not closeToWater do
                coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ)
                hit, hitPos = TestProbeAgainstWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z)
                if hit then
                    closeToWater = true
                end
                startZ = startZ - 0.1
            end
            startZ = 0
            startY = startY + 0.25
        end
        local startZ = 0
        local startY = 0
        if closeToWater then
            while startY < 50 and not canFish do
                while startZ > -20 and not canFish do
                    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ)
                    hit, hitPos = TestProbeAgainstWater(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z)
                    if hit then
                        local offset = GetOffsetFromEntityInWorldCoords(playerped, 0.0, startY, startZ - 20)
                        local bool, groundZ, normal = GetGroundZFor_3dCoord(hitPos.x, hitPos.y, hitPos.z)
                        if hitPos.z - groundZ >= 1.25 then
                            canFish = true
                        else
                            hit = false
                        end
                        break
                    end
                    startZ = startZ - 0.1
                end
                startZ = 0
                startY = startY + 0.25
            end
            if canFish then
                if QBCore.Functions.HasItem("fishingrod", 1) then
                    cancel = false
                    fishingPOS = coordA
                    Fish(false)
                end
            else
                QBCore.Functions.Notify('The water isn\'t deep enough here', "error", 7500)
            end
        else
            QBCore.Functions.Notify('You aren\'t close enough to water and/or facing the right direction', "error", 7500)
        end
    end
end  


function Fish(isOnWaterCraft)
    if cancel == false then
        if QBCore.Functions.HasItem(bait, 1) then
            local ply = PlayerPedId()
            --playerAnim()
            TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
            Citizen.Wait(50)
            TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
            FishingCheck()
            isFishing = true
            local startTime = GetGameTimer()
            timer = exports['qb-core']:qbRandomNumber(15000,35000)
            if (exports["erp-assets"]:getFishingSpeedBoost() - GetGameTimer()) > 0 then
                timer = exports['qb-core']:qbRandomNumber(15000, 27000)
                QBCore.Functions.Notify('Catch Speed Boost: You have ' .. math.floor((exports["erp-assets"]:getFishingSpeedBoost() - GetGameTimer()) / 1000 + 0.5) .. "s left to your boost", "primary", 7500)
            end
            while cancel == false and (GetGameTimer() - startTime) < timer do
                Citizen.Wait(1)
            end
            Catch(isOnWaterCraft)
        else
            QBCore.Functions.Notify('You don\'t have enough of bait type ' .. bait, "error", 7500)
            isFishing = false
        end
    end
end

local isChecking = false

function FishingCheck()
    if not isChecking then
        isChecking = true
        Citizen.CreateThread(function()
            while IsPedUsingScenario(GetPlayerPed(-1), 'WORLD_HUMAN_STAND_FISHING') do
                Citizen.Wait(250)
            end
            if isFishing then
                QBCore.Functions.Notify('You moved and stopped fishing', "error", 7500)
            end
            isFishing = false
            cancel = true
            isChecking = false
        end)
    end
end


function Repeat(isOnWaterCraft)
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(playerped, 1)
    if #(fishingPOS - coordA) > 3.0 and not isOnWaterCraft then
        QBCore.Functions.Notify('You stopped fishing because you moved.', "error", 7500)
        SetCurrentPedWeapon(ply, 'WEAPON_UNARMED', true)
        ClearPedTasksImmediately(ply)
        cancel = true
    end
    if cancel == false then
        if QBCore.Functions.HasItem(bait,1) then
            Citizen.Wait(450)
            local ply = PlayerPedId()
            cancel = false
            isFishing = true
            TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
            Citizen.Wait(50)
            TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
            FishingCheck()
            isFishing = true
            local startTime = GetGameTimer()
            timer = exports['qb-core']:qbRandomNumber(15000,35000)
            if (exports["erp-assets"]:getFishingSpeedBoost() - GetGameTimer()) > 0 then
                timer = exports['qb-core']:qbRandomNumber(15000, 27000)
                QBCore.Functions.Notify('Catch Speed Boost: You have ' .. math.floor((exports["erp-assets"]:getFishingSpeedBoost() - GetGameTimer()) / 1000 + 0.5) .. "s left to your boost", "primary", 7500)
            end
            while cancel == false and (GetGameTimer() - startTime) < timer do
                Citizen.Wait(1)
            end
            Catch(isOnWaterCraft)
        else
            QBCore.Functions.Notify('You don\'t have enough of bait type ' .. bait, "error", 7500)
            isFishing = false
        end
    end
end

function Catch(isOnWaterCraft)
    local playerped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(playerped, 1)
    if #(fishingPOS - coordA) > 3.0 and not isOnWaterCraft then
        cancel = true
        QBCore.Functions.Notify('You stopped fishing because you moved.', "error", 7500)
    end
    if cancel == false then
        local ply = PlayerPedId()
        QBCore.Functions.Notify('There is a fish on the line.', "primary", 7500)
        local catching = true
        local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
        Skillbar.Start({
            duration = 2000,
            pos = exports['qb-core']:qbRandomNumber(10, 30),
            width = exports['qb-core']:qbRandomNumber(7, 14),
        }, function()
            Citizen.Wait(175)
            local multiplier = 0
            local handlingSkillbar = true
            local Skillbar2 = exports['qb-skillbar']:GetSkillbarObject()
            Skillbar2.Start({
                duration = 750,
                pos = exports['qb-core']:qbRandomNumber(5, 30),
                width = exports['qb-core']:qbRandomNumber(7, 10),
            }, function()
                multiplier = exports['qb-core']:qbRandomNumber(1,2)
                handlingSkillbar = false
            end, function() handlingSkillbar = false end)
            while handlingSkillbar do
                Citizen.Wait(50)
            end
            if isOnWaterCraft then
                multiplier = multiplier + 1
                local depth = getDepth()
                print(math.floor((depth/45.0)+0.5))
                multiplier = multiplier + math.floor((depth/45.0)+0.5)
            end
            if QBCore.Functions.HasItem("fishingrod",1) then
                if QBCore.Functions.HasItem(bait,1) then
                    isFishing = false
                    local rdn = exports['qb-core']:qbRandomNumber(1,100)
                    if rdn <= 5 then
                        TriggerServerEvent("qb-inventory-sv:RemoveItem", "fishingrod", 1, nil, true)
                        TriggerServerEvent("qb-inventory-sv:RemoveItem", bait, 1, nil, true)
                        SetCurrentPedWeapon(ply, 'WEAPON_UNARMED', true)
                        ClearPedTasksImmediately(ply)
                        catching = false
                    elseif rdn >= 6 then
                        QBCore.Functions.Notify('You caught a Fish!', "primary", 7500)
                        local luckBoostEndTime = exports["erp-assets"]:getFishingSpeedBoost()
                        TriggerServerEvent('erp-fish:getFish', bait, multiplier, inZone, GetEntityCoords(GetPlayerPed(-1), false), (luckBoostEndTime - GetGameTimer()))
                        local rdn = exports['qb-core']:qbRandomNumber(1,100)
                        if rdn <= 15 then
                            TriggerServerEvent("qb-inventory-sv:RemoveItem", bait, 1, nil, true)
                        end
                        SetCurrentPedWeapon(ply, 'WEAPON_UNARMED', true)
                        ClearPedTasksImmediately(ply)
                        catching = false
                        Repeat(isOnWaterCraft)
                    end
                else
                    catching = false
                    QBCore.Functions.Notify('Where did your bait go? How did you manage to catch that fish without that? Cheeky bastard. Keep that in your inventory.', "error", 7500)
                end
            else
                catching = false
                QBCore.Functions.Notify('Where did your fishing rod go? How did you manage to catch that fish without one? Cheeky bastard. Keep that thing in your inventory.', "error", 7500)
            end
        end, function()
            local rdn = exports['qb-core']:qbRandomNumber(1,100)
            if rdn <= 25 then
                QBCore.Functions.Notify('The fish got away and took your bait.', "error", 7500)
                TriggerServerEvent("qb-inventory-sv:RemoveItem", bait, 1, nil, true)
            else
                QBCore.Functions.Notify('The fish got away.', "error", 7500)
            end
            catching = false
            Repeat(isOnWaterCraft)
        end)
        while catching do
            Citizen.Wait(50)
        end
    end
end


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

AddEventHandler("erp-fish-cl:SellFish", function(data)
    if not sellingFish then
        sellingFish = true
        SellItems(data.args[1])
    else
        sellingFish = false
    end
end)

function SellItems(saltWaterFish)
    local level = 1
    local fishJob = QBCore.Functions.GetLegalJob("fish")
    for i = 2, #fishJob.repLevels, 1 do
        if QBCore.Functions.GetPlayerData().metadata.jobrep["fish"] >= fishJob.repLevels[i] then
            level = i
        else
            break
        end
    end
    while sellingFish do
        sellfish = fishJob.pay[1].rewards[level][1].amount * 2
        local hasenough = false
        local fishName = ""
        if saltWaterFish then
            if QBCore.Functions.HasItem("fish",2) then 
                fishName = "fish"
                hasenough = true
            elseif QBCore.Functions.HasItem("fish1",2) then 
                fishName = "fish1"
                hasenough = true
            elseif QBCore.Functions.HasItem("fish2",2) then 
                fishName = "fish2"
                hasenough = true
            else
                QBCore.Functions.Notify('You dont have enough fish in your pockets to sell!', "error", 7500)
            end
        else
            if QBCore.Functions.HasItem("bluegill",2) then 
                fishName = "bluegill"
                hasenough = true
            elseif QBCore.Functions.HasItem("redtail",2) then 
                fishName = "redtail"
                hasenough = true
            elseif QBCore.Functions.HasItem("walleye",2) then 
                fishName = "walleye"
                hasenough = true
            elseif QBCore.Functions.HasItem("perch",2) then 
                fishName = "perch"
                hasenough = true
            elseif QBCore.Functions.HasItem("largemouth",2) then 
                fishName = "largemouth"
                hasenough = true
            elseif QBCore.Functions.HasItem("tilapia",2) then 
                fishName = "tilapia"
                hasenough = true
            else
                QBCore.Functions.Notify('You dont have enough fish in your pockets to sell!', "error", 7500)
            end
        end
        if hasenough then
            TriggerServerEvent("erp-fish:takeMoney", 1)
            local finished = nil
			QBCore.Functions.Progressbar("fish_job", "Selling Fish", 2000, false, true, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				finished = 100
			end, function()
                finished = 0
                sellingFish = false
            end)
			while finished == nil do
                Citizen.Wait(5)
			end
            if finished == 100 then
                if QBCore.Functions.HasItem(fishName,2) then 
                    TriggerServerEvent('erp-fish:payShit', sellfish)
                    TriggerServerEvent("qb-inventory-sv:RemoveItem", fishName, 2, nil, true)
                end
            end
        else
            sellingFish = false
        end
    end
end

local blips = {
    {title="Rooster Rest", colour=48, id=206, scale=0.6, x = -178.67, y = 314.27, z = 97.97},
    {title="S. Ho Fresh Water Sushi", colour=48, id=120, scale=0.6, x = -643.25, y = -1228.02, z = 11.55}
 }
     
Citizen.CreateThread(function()
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
end)

exports("getDepthFromFinder", getDepthFromFinder)