local timer = 0

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)

    end
end)

RegisterNetEvent('RNG_CarBomb:CheckIfRequirementsAreMet')
AddEventHandler('RNG_CarBomb:CheckIfRequirementsAreMet', function()
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 3.000, 0, 70)
    local vCoords = GetEntityCoords(veh)
    local dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, vCoords.x, vCoords.y, vCoords.z, false)
    local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
    local anim = "weed_spraybottle_crouch_base_inspector"

    if not IsPedInAnyVehicle(ped, false) then
        if veh and (dist < 3.0) then
            loadAnimDict(animDict)
            Citizen.Wait(1000)
            TaskPlayAnim(ped, animDict, anim, 3.0, 1.0, -1, 0, 1, 0, 0, 0)
            if Config.UsingProgressBars then
                exports['progressBars']:startUI(Config.TimeTakenToArm * 1000, "Arming the IED")
            end
            Citizen.Wait(Config.TimeTakenToArm * 1000)
            ClearPedTasksImmediately(PlayerPedId())
            TriggerServerEvent('RNG_CarBomb:RemoveBombFromInv')
            RunTimer(veh)
        else
            if Config.UsingMythicNotifications then
                TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'No vehicle nearby'})
            end
        end
    else
        if Config.UsingMythicNotifications then
            TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'You cannot do this from inside a vehicle!'})
        end
    end
end)

function RunTimer(veh)
    timer = Config.TimeUntilDetonation
    while timer > 0 do
        timer = timer - 1
        Citizen.Wait(1000)
        if timer == 0 then
            DetonateVehicle(veh)
        end
    end
end

function DetonateVehicle(veh)
    local vCoords = GetEntityCoords(veh)
    if DoesEntityExist(veh) then
        AddExplosion(vCoords.x, vCoords.y, vCoords.z, 5, 50.0, true, false, true)
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(20)
    end
end