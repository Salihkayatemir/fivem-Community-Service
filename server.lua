RegisterNetEvent('police:server:RageCommunitySentence', function(playerId, PunishmentCount)
    local src = source
    local punishment = PunishmentCount
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not OtherPlayer or Player.PlayerData.job.type ~= 'leo' then return end
---------------------------------------------------------------------------------------------------------------------------
    TriggerClientEvent('police:client:RageCommunitySentenceGetCriminalInfo', playerId, Player, OtherPlayer, punishment, true)
    TriggerClientEvent('QBCore:Command:TeleportToCoords', playerId, 161.34, -997.14, 29.35)
end)
