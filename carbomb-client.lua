local timer = 0
local placed = false
local remoteplaced = false
local checkseats = false
local InstantDeflagrSeatBusy = false
local armedVeh

Citizen.CreateThread(function()
	while true do
        Wait(0)
        if Config.SpeedDeflagr then
            if placed then
                local ped = GetPlayerPed(-1)
                local SpeedKM = GetEntitySpeed(armedVeh)*3.6
                local SpeedMPH = GetEntitySpeed(armedVeh)*2.236936
                --print('Speed: ' ..SpeedKM)
                
                if Config.UseMPH then
                    if SpeedMPH > Config.maxSpeed then
                        DetonateVehicle(armedVeh)
                        placed = false
                    end
                end    
                
                if Config.UseKMH then
                    if SpeedKM > Config.maxSpeed then
                        DetonateVehicle(armedVeh)
                        placed = false
                    end 
                end     
            end   
        elseif Config.RemoteTrigger then
            local ped = GetPlayerPed(-1)
            if IsControlJustReleased(0, Config.TriggerKey) and remoteplaced then
                DetonateVehicle(armedVeh)
                remoteplaced = false
            end          
        elseif Config.DelayedTimer then
            if not IsVehicleSeatFree(armedVeh, -1) and checkseats  then
                --print('Driver Busy')
                RunTimer(armedVeh)
                checkseats = false
            elseif not IsVehicleSeatFree(armedVeh, 0) and checkseats then   
                --print('Passenger Busy')
                RunTimer(armedVeh)
                checkseats = false
            end
        elseif Config.InstantDeflagrSeatBusy then
            if not IsVehicleSeatFree(armedVeh, -1) and InstantDeflagrSeatBusy then  
                DetonateVehicle(armedVeh)
                InstantDeflagrSeatBusy = false
            end          
        end    
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
                exports['progressBars']:startUI(Config.TimeTakenToArm * 1000, _U('arming'))
            end
            if Config.UsingMythicProgbar then
                FastMythticProg(_U('arming'), Config.TimeTakenToArm * 1000)
            end
            Citizen.Wait(Config.TimeTakenToArm * 1000)
            ClearPedTasksImmediately(PlayerPedId())
            TriggerServerEvent('RNG_CarBomb:RemoveBombFromInv')
            
            if Config.Vanilla then
                --print(veh)
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('vanilla') .. Config.TimeUntilDetonation .. ' secondi', length = 5500})
                else
                    ShowNotification(_U('vanilla') .. Config.TimeUntilDetonation .. ' seconds')  
                end
                RunTimer(veh)
            end          

            if Config.SpeedDeflagr then
                if Config.UsingMythicNotifications then
                    if Config.UseKMH then
                        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('speed') .. Config.maxSpeed .. ' Kmh', length = 5500})
                    elseif Config.UseMPH then
                        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('speed') .. Config.maxSpeed .. ' MPH', length = 5500})
                    end     
                else
                    if Config.UseKMH then
                        ShowNotification(_U('speed') .. Config.maxSpeed .. ' Kmh') 
                    elseif Config.UseMPH then
                        ShowNotification(_U('speed') .. Config.maxSpeed .. ' MPH')
                    end         
                end
                placed = true
                -- print(placed)
            end  

            if Config.RemoteTrigger then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('remote'), length = 5500})
                else
                    ShowNotification(_U('remote'))    
                end 
                remoteplaced = true
                -- print('Remote placed') -- Debug
                -- print(remoteplaced)
            end  

            if Config.DelayedTimer then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('delayed') .. Config.TimeUntilDetonation .. ') secondi', length = 5500})
                else
                    ShowNotification(_U('delayed') .. Config.TimeUntilDetonation .. ' secondi)')    
                end 
                checkseats = true   
            end
            
            if Config.InstantDeflagrSeatBusy then
                if Config.UsingMythicNotifications then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('instant'), length = 5500})
                else
                    ShowNotification(_U('instant'))    
                end 
                InstantDeflagrSeatBusy = true
            end    

            armedVeh = veh -- Global assignment to the car
            
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