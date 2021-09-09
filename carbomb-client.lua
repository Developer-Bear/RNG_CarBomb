local timer = 0
local armedVeh
local ped = GetPlayerPed(-1)

RegisterNetEvent('RNG_CarBomb:CheckIfRequirementsAreMet')
AddEventHandler('RNG_CarBomb:CheckIfRequirementsAreMet', function()
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 3.000, 0, 71)
    local vCoords = GetEntityCoords(veh)
    local dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, vCoords.x, vCoords.y, vCoords.z, false)
    local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
    local anim = "weed_spraybottle_crouch_base_inspector"

    if not IsPedInAnyVehicle(ped, false) then
        if veh and (dist < 3.0) then
            loadAnimDict(animDict)
            Citizen.Wait(1000)
            TaskPlayAnim(ped, animDict, anim, 3.0, 1.0, -1, 0, 1, 0, 0, 0)
            if Config.ProgressBarType == 0 then
                return
            elseif Config.ProgressBarType == 1 then
                exports['progressBars']:startUI(Config.TimeTakenToArm * 1000, _U('arming'))
            elseif Config.ProgressBarType == 2 then
                FastMythticProg(_U('arming'), Config.TimeTakenToArm * 1000)
            end
            Citizen.Wait(Config.TimeTakenToArm * 1000)
            ClearPedTasksImmediately(ped)
            TriggerServerEvent('RNG_CarBomb:RemoveBombFromInv')
            
            if Config.DetonationType == 0 then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('vanilla', Config.TimeUntilDetonation), length = 5500})
                else
                    ShowNotification(_U('vanilla', Config.TimeUntilDetonation))  
                end
                RunTimer(veh)
            elseif Config.DetonationType == 1 then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('speed', Config.maxSpeed, Config.Speed), length = 5500})
                else
                    ShowNotification(_U('speed', Config.maxSpeed, Config.Speed)) 
                end
                armedVeh = veh
            elseif Config.DetonationType == 2 then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('remote'), length = 5500})
                else
                    ShowNotification(_U('remote'))
                end
                armedVeh = veh
            elseif Config.DetonationType == 3 then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('delayed', Config.TimeUntilDetonation), length = 5500})
                else
                    ShowNotification(_U('delayed', Config.TimeUntilDetonation))    
                end 
                armedVeh = veh 
            elseif Config.DetonationType == 4 then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('instant'), length = 5500})
                else
                    ShowNotification(_U('instant'))    
                end 
                armedVeh = veh
            end 
            
            while armedVeh do
                Citizen.Wait(0)
                if Config.DetonationType == 1 and armedVeh then
                    local speed = GetEntitySpeed(armedVeh)
                    local SpeedKMH = speed * 3.6
                    local SpeedMPH = speed * 2.236936
                    
                    if Config.Speed == 'MPH' then
                        if SpeedMPH >= Config.maxSpeed then
                            DetonateVehicle(armedVeh)
                        end
                    elseif Config.Speed == 'KPH' then
                        if SpeedKMH >= Config.maxSpeed then
                            DetonateVehicle(armedVeh)
                        end 
                    end        
                elseif Config.DetonationType == 2 and armedVeh then
                    if IsControlJustReleased(0, Config.TriggerKey) then
                        DetonateVehicle(armedVeh)
                    end          
                elseif Config.DetonationType == 3 and armedVeh then
                    if not IsVehicleSeatFree(armedVeh, -1)  then
                        RunTimer(armedVeh)
                    elseif not IsVehicleSeatFree(armedVeh, 0) then   
                        RunTimer(armedVeh)
                    end
                elseif Config.DetonationType == 4 and armedVeh then
                    if not IsVehicleSeatFree(armedVeh, -1) then  
                        DetonateVehicle(armedVeh)
                    end          
                end    
            end
        else
            if Config.UsingMythicNotifications then
                TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('novehnearby'), length = 5500})
            else
                ShowNotification(_U('novehnearby'))    
            end 
        end 
    else
        if Config.UsingMythicNotifications then
            TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('cantinside'), length = 5500})
        else
            ShowNotification(_U('cantinside'))    
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
        armedVeh = nil
        AddExplosion(vCoords.x, vCoords.y, vCoords.z, 5, 50.0, true, false, true)
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(20)
    end
end

function FastMythticProg(message, time)
    exports['mythic_progbar']:Progress({
		name = "tint",
		duration = time,
		label = message,
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
	}, function(cancelled)
        if not cancelled then
            
		else
			Citizen.Wait(1000)
		end
	end)
end

function ShowNotification( text )
    SetNotificationTextEntry( "STRING" )
    AddTextComponentString( text )
    DrawNotification( false, false )
end
