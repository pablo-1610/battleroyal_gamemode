local NearZone = false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        if not NearZone then
            Wait(2500)
        else
            Wait(50)
        end
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        SendNUIMessage({
            status = "position",
            x = pos.x,
            y = pos.y,
            z = pos.z
        })
    end
end) 


MusicZone = {
}

Citizen.CreateThread(function()
    Wait(2000)
    while true do
        NearZone = false
        local pPed = GetPlayerPed(-1)
        local pCoords = GetEntityCoords(pPed)
        for k,v in pairs(MusicZone) do
            local dst = GetDistanceBetweenCoords(pCoords, v.pos, true)
            if not NearZone then
                if dst < v.starting then
                    NearZone = true
                    if soundExists(v.name) then
                        Resume(v.name)
                    else
                        PlayUrlPos(v.name, v.link, v.max, v.pos, true)
                        setVolumeMax(v.name, v.max)
                        Distance(v.name, v.dst)
                    end
                else
                    if soundExists(v.name) then
                        if not isPaused(v.name) then
                            Pause(v.name)
                        end
                    end
                end
            end
        end

        if not NearZone then
            Wait(350)
        else
            Wait(50)
        end
    end
end)