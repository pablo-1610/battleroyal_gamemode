function trace(msg)
    print("^1[Pablo's BR] ^7"..msg)
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(1) end
    local spawn = {vector3(-33.7, -4.09, 71.23), heading = 100.0}



        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)


        local ped = PlayerPedId()


        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)

        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, true, true, false)


        ClearPedTasksImmediately(ped)

        RemoveAllPedWeapons(ped) 
        ClearPlayerWantedLevel(PlayerId())



        local time = GetGameTimer()

        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
            Citizen.Wait(0)
        end

        ShutdownLoadingScreen()

        if IsScreenFadedOut() then
            DoScreenFadeIn(500)

            while not IsScreenFadedIn() do
                Citizen.Wait(0)
            end
        end


        TriggerEvent('playerSpawned', spawn)

        if cb then
            cb(spawn)
        end

        spawnLock = false

        local possibles = {
            "a_m_m_beach_01",
            "a_m_m_beach_02",
            "a_m_m_eastsa_01",
            "a_m_m_salton_03",
            "a_m_m_bevhills_02"
        }

        local mod = GetHashKey(possibles[math.random(1,#possibles)])
        RequestModel(mod)
        while not HasModelLoaded(mod) do Citizen.Wait(10) end
        SetPlayerModel(PlayerId(), mod)
        SetPedDefaultComponentVariation(PlayerPedId())

        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), true, true)

        Citizen.CreateThread(function()
            local waypointCoords = spawn
            local foundGround, zCoords, zPos = false, -500.0, 0.0

            while not foundGround do
                zCoords = zCoords + 10.0
                RequestCollisionAtCoord(waypointCoords.x, waypointCoords.y, zCoords)
                Citizen.Wait(0)
                foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, zCoords)

                if not foundGround and zCoords >= 2000.0 then
                    foundGround = true
                end
            end

            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, zPos)
        end)

        
        
        FreezeEntityPosition(PlayerPedId(), false)

        for v in EnumeratePeds() do
            if v ~= PlayerPedId() then
                ResetEntityAlpha(v)
                SetEntityNoCollisionEntity(v, pPed, true)
                NetworkConcealPlayer(NetworkGetPlayerIndexFromPed(v), false, 1)
                SetEntityVisible(v, true, 0)
            end
        end

        
        gameLoop()
        

end)

local playerState = 0

RegisterCommand("co", function()
    local p = GetEntityCoords(PlayerPedId())
    trace(p.x..", "..p.y..", "..p.z.." | "..GetEntityHeading(PlayerPedId()))
end, false)

function gameLoop()
    Citizen.CreateThread(function()
        trace("Anti NPC is ok and ready")
        
        
        while true do
            Citizen.Wait(1)
            ClearPlayerWantedLevel(GetPlayerIndex())
		RestorePlayerStamina(PlayerId(), 1.0)
            DisablePlayerVehicleRewards(PlayerId())
            HideHudComponentThisFrame(3)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        end
    end)

    Citizen.CreateThread(function()
        while playerState == 0 do
            Citizen.Wait(1)
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            for v in EnumeratePeds() do
                if v ~= PlayerPedId() then
                    SetEntityAlpha(v, 0, 0)
                    SetEntityNoCollisionEntity(PlayerPedId(), v, false)
                    NetworkConcealPlayer(NetworkGetPlayerIndexFromPed(v), true, 1)
                end
            end
        end
        EnableAllControlActions(0)
        EnableAllControlActions(1)
        for v in EnumeratePeds() do
            if v ~= PlayerPedId() then
                ResetEntityAlpha(v)
                SetEntityNoCollisionEntity(v, PlayerPedId(), true)
                NetworkConcealPlayer(NetworkGetPlayerIndexFromPed(v), false, 1)
            end
        end
    end)

    local var = "~o~"
    Citizen.CreateThread(function()
        while playerState == 0 do
            Citizen.Wait(750)
            if var == "~o~" then var = "~y~" else var = "~o~" end
        end
    end)

    Wait(2000)
    trace("Calling music player...")
    PlayUrl("MAIN", "https://youtu.be/vT7f8pQcgR0", 0.12, true)
    
    
    trace("Battle Royal->[NUI]->Music player = OK")

    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do Citizen.Wait(1) end
    SetEntityCoords(PlayerPedId(), -26.70, -92.71, 56.25, 0,0,0,0)
    SetEntityHeading(PlayerPedId(), 82.5)
    GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_ASSAULTRIFLE"), 1500, false, true)
    

    FreezeEntityPosition(PlayerPedId(), 1)
    
    
    Wait(2500)
    DoScreenFadeIn(1500)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 0)
    SetCamActive(cam, 1)
    SetCamCoord(cam, -32.19, -91.05, 57.25)
    SetCamFov(cam, 12.0)
    --SetCamFov(cam, 75.0)

    local baseCam = GetEntityCoords(PlayerPedId())
    

    --PointCamAtEntity(cam, ped, 0,0,0,0)
    PointCamAtCoord(cam, vector3(baseCam.x, baseCam.y, baseCam.z+0.5))

    RenderScriptCams(1, 1, 0, 0, 0)
    
    RMenu.Add('arrival', "arrival_main", RageUI.CreateMenu("Battle Royal", "~r~Préparez-vous pour la guerre~s~"))
    RMenu:Get("arrival", "arrival_main").Closed = function()end
    RMenu:Get("arrival", "arrival_main").Closable = false

    RageUI.Visible(RMenu:Get("arrival",'arrival_main'), true)

    Citizen.CreateThread(function()
        local ok = true
        while playerState == 0 do
            RageUI.IsVisible(RMenu:Get("arrival",'arrival_main'),true,true,true,function()
                RageUI.Separator(var.."Pablo's Battle Royal — Alpha")
                RageUI.Separator("↓ ~r~Statistiques ~s~↓")
                RageUI.ButtonWithStyle("Ratio, KD & Gunfights",nil, {RightLabel = "→→"}, false, function(_,_,s)
                end)
                RageUI.ButtonWithStyle("Victoires et défaites",nil, {RightLabel = "→→"}, false, function(_,_,s)
                end)
                RageUI.ButtonWithStyle("Classement",nil, {RightLabel = "→→"}, false, function(_,_,s)
                end)
                RageUI.Separator("↓ ~r~Actions ~s~↓")
                RageUI.ButtonWithStyle("Jouer",nil, {RightLabel = var.."Accès au lobby ~s~→→"}, ok, function(_,_,s)
                    if s then
                        ok = false
                        DoScreenFadeOut(1000)
                        while not IsScreenFadedOut() do Citizen.Wait(10) end 
                        RenderScriptCams(0, 1, 0, 0, 0)
                        RageUI.Visible(RMenu:Get("arrival",'arrival_main'), false)
                        playerState = 1
                        FreezeEntityPosition(PlayerPedId(), false)
                        SetEntityCoords(PlayerPedId(),2.6968, -667.0166, 16.13061,0,0,0,0)
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        NetworkSetFriendlyFireOption(false)
                        SetCanAttackFriendly(PlayerPedId(), false, true)
                        Wait(500)
                        Destroy("MAIN")
                        PlayUrl("MAIN", "https://youtu.be/N79QODkgMPs", 0.12, true)
                        DoScreenFadeIn(1000)
                        TriggerServerEvent("p_br:connected")
                        initializeLobby()
                    end
                end)
                RageUI.ButtonWithStyle("Boutique",nil, {RightLabel = "→→"}, false, function(_,_,s) 
                end)
                RageUI.ButtonWithStyle("Crédits",nil, {RightLabel = "→→"}, false, function(_,_,s) 
                end)
            end, function()    
            end, 1)
            Citizen.Wait(0)
        end
    end)
end

local lobbyInfos,launchwith,toWait = {},0,80

RegisterNetEvent("p_br:callbackLobbyInfos")
AddEventHandler("p_br:callbackLobbyInfos", function(infos)
    print("Infos get")
    print(json.encode(infos))
    lobbyInfos = infos
end)

RegisterNetEvent("p_br:launch")
AddEventHandler("p_br:launch", function(players)
    if playerState == 2 or playerState == 0 then return end
    launchwith = players
    playerState = 2
    Destroy("MAIN")
    PlayUrl("MAIN", "https://youtu.be/UrAhnndvrSU", 0.20, false)
    Citizen.CreateThread(function()
        while playerState == 2 do
            Citizen.Wait(1000)
            toWait = toWait - 1
            if toWait <= 0 then
                playerState = 3
            end
        end
    end)
end)

function initializeLobby()
    while lobbyInfos.max == nil do Citizen.Wait(10) end
    print("Test")
    local point = ""
    Citizen.CreateThread(function()
        while playerState == 1 do
            Citizen.Wait(1)
            RageUI.Text{message = "En attente de joueurs"..point.."\nLobby: ~y~"..lobbyInfos.actual.."~s~/~y~"..lobbyInfos.max.."~s~ | Serveur n°: ~r~"..lobbyInfos.sID}
        end
        while playerState == 2 do
            Citizen.Wait(1)
            RageUI.Text{message = "Lancement de la partie avec ~b~"..launchwith.." joueurs~s~ dans ~y~"..toWait.."s~s~"..point}
        end
        while playerState == 3 do
            Citizen.Wait(1)
            RageUI.Text{message = "En attente de la ~r~synchronisation serveur~s~, veuillez patienter~s~"..point}
        end
        while playerState == 4 do
            Citizen.Wait(1)
            RageUI.Text{message = "~r~Invincibilité restante~s~: ~y~"..toWait.."s"}
        end
    end)
    Citizen.CreateThread(function()
        while playerState == 1 or playerState == 2 or playerState == 3 do
            Citizen.Wait(750)
            if point == "" then
                point = "."
            elseif point == "." then
                point = ".."
            elseif point == ".." then
                point = "..."
            else
                point = ""
            end
        end
    end)
    TriggerServerEvent("p_br:requestGameState")
end

RegisterNetEvent("p_br:cbGameState")
AddEventHandler("p_br:cbGameState", function(gameState, players, count)
    if gameState == 1 then
        launchwith = players
        toWait = count
        Citizen.CreateThread(function()
            while playerState == 2 do
                Citizen.Wait(1000)
                toWait = toWait - 1
                if toWait <= 0 then
                    playerState = 3
                end
            end
        end)
    end
end)

RegisterNetEvent("p_br:drop")
AddEventHandler("p_br:drop", function()
    if playerState == 0 then return end
    if playerState == 4 then return end

    
    --local x = math.random(-2550, 3900)
    --local y = math.random(-2750, 7000)
    local z = 2500.0

    GiveWeaponToPed(PlayerPedId(), GetHashKey("GADGET_PARACHUTE"), 1000, false, true)
    SetEntityCoords(PlayerPedId(), x,y,z, 0,0,0,0)
    toWait = 60
    playerState = 4
    Citizen.CreateThread(function()
        while playerState == 4 do
            Citizen.Wait(1000)
            toWait = toWait - 1
            if toWait <= 0 then
                SetEntityInvincible(PlayerPedId(), false)
                NetworkSetFriendlyFireOption(true)
                SetCanAttackFriendly(PlayerPedId(), true, true)
                playerState = 5
            end
        end
    end)
    

end)