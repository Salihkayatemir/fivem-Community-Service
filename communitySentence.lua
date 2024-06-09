-- RAGE Community Sentence
QBCore = exports['qb-core']:GetCoreObject()
local isCriminal = false
local punishment = 0
local markers = {}

CreateThread(function()
    local publicpunishment = BoxZone:Create(vector3(189.45, -942.18, 50.74), 150, 100, { -- Set the length and width diameter that the character cannot exit
        name="qb-publicpunishment",
        heading=340,
        debugPoly=false
    })

    publicpunishment:onPlayerInOut(function(isPlayerInside)
        local ped = PlayerPedId()
        local car = GetVehiclePedIsIn(ped, false)
        if isCriminal then
            if car ~= 0 then
                TaskLeaveVehicle(ped, car, 16)
                QBCore.Functions.Notify('Araçtan ayrıldın', "error")
            end
            if isPlayerInside then
                QBCore.Functions.Notify('Kamu cezalarını bitirmelisin.', "error")
            else
                QBCore.Functions.Notify('Kamu cezalarını bitirmeden ayrılamazsın!', "error")
                TriggerEvent('QBCore:Command:TeleportToPlayer', vector3(161.34, -997.14, 29.35))
            end
        else
            return
        end
    end)
end)


RegisterCommand('kamuver', function() 
    TriggerEvent('police:client:RageCommunitySentence')
end)

RegisterNetEvent('police:client:RageCommunitySentence', function()
    local src = source    
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.type ~= 'leo' then 
        QBCore.Functions.Notify('Polis olmalısın.', "error")
    else
        local dialog = exports['qb-input']:ShowInput({
            header = "Kamu Cezası",
            submitText = "Gönder",
            inputs = {
                {
                    text = "ID",
                    name = "punished",
                    type = "number",
                    isRequired = true
                },
                {
                    text = "Kamu Adeti",
                    name = "punishmentCount",
                    type = "number",
                    isRequired = true
                }
            }
        })
        if tonumber(dialog['punishmentCount']) > 0 and tonumber(dialog['punished']) > 0 then
            QBCore.Functions.Notify('başarılı', "success")
            TriggerServerEvent("police:server:RageCommunitySentence", tonumber(dialog['punished']), tonumber(dialog['punishmentCount']))
        else
            QBCore.Functions.Notify("0'dan büyük kamu ve ID girmelisin!", "success")
        end 
    end 
end)

RegisterNetEvent('police:client:RageCommunitySentenceGetCriminalInfo', function(Player, OtherPlayer, punishmentInfo, isClientCriminal)
    punishment = punishmentInfo
    isCriminal = isClientCriminal
    if isCriminal then
        CreateMarkers(punishment)
    end
end)

function CreateMarkers(count)
    markers = {}
    for i = 1, count do
        local point = Config.cleanupPoints[math.random(1, #Config.cleanupPoints)]
        markers[i] = {
            coords = point,
            cleaned = false
        }
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function RageDrawScreenText(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

CreateThread(function()
    while true do
        Wait(0)
        if isCriminal and punishment and punishment > 0 then
            RageDrawScreenText('Kalan kamu: '..punishment,4,0.04,0.5,0.40, 255, 1, 1, 180)
            for i, marker in pairs(markers) do
                if not marker.cleaned then
                    DrawMarker(2, marker.coords.x, marker.coords.y, marker.coords.z+0.5 - 1.0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 255, false, false, 2, false, nil, nil, false)
                    if IsControlJustReleased(0, 38) then -- E key
                        local playerPos = GetEntityCoords(PlayerPedId())
                        if #(playerPos - marker.coords) < 1.5 then
                            -- Play cleaning animation with a broom
                            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_JANITOR", 0, true)
                            Wait(5000) -- Wait for 10 seconds to simulate cleaning
                            ClearPedTasks(PlayerPedId())
                            marker.cleaned = true
                            punishment = punishment - 1
                            QBCore.Functions.Notify('Temizleme işlemi tamamlandı.', "success")
                            if punishment <= 0 then
                                QBCore.Functions.Notify('Tüm cezalarını tamamladın.', "success")
                                isCriminal = false
                            else
                                CreateMarkers(punishment)
                            end
                        end
                    end
                    -- Display the text near the marker
                    local playerPos = GetEntityCoords(PlayerPedId())
                    if #(playerPos - marker.coords) < 5.0 then
                        DrawText3D(marker.coords.x, marker.coords.y, marker.coords.z, "E basarak temizleyin")
                    end
                end
            end
        end
    end
end)
