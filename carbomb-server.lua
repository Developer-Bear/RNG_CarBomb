ESX = nil

TriggerEvent('tac:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('ied', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem('ied').count > 0 then
        TriggerClientEvent('RNG_CarBomb:CheckIfRequirementsAreMet', source)
    end
end)

RegisterServerEvent('RNG_CarBomb:RemoveBombFromInv')
AddEventHandler('RNG_CarBomb:RemoveBombFromInv', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getInventoryItem('ied').count > 0 then
        xPlayer.removeInventoryItem('ied', 1)
    end
end)