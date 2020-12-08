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

        local mod = GetHashKey("mp_m_freemode_01")
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
            DisablePlayerVehicleRewards(PlayerId())
            HideHudComponentThisFrame(3)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        end
    end)

    --[[Citizen.CreateThread(function()
        while playerState == 0 do
            Citizen.Wait(1)
            DisableControlAction(1, 1, true)
            DisableControlAction(1, 2, true)
            DisableControlAction(1, 4, true)
            DisableControlAction(1, 6, true)
            DisableControlAction(1, 270, true)
            DisableControlAction(1, 271, true)
            DisableControlAction(1, 272, true)
            DisableControlAction(1, 273, true)
            DisableControlAction(1, 282, true)
            DisableControlAction(1, 283, true)
            DisableControlAction(1, 284, true)
            DisableControlAction(1, 285, true)
            DisableControlAction(1, 286, true)
            DisableControlAction(1, 290, true)
            DisableControlAction(1, 291, true)
            for v in EnumeratePeds() do
                if v ~= PlayerPedId() then
                    SetEntityAlpha(v, 0, 0)
                    SetEntityNoCollisionEntity(PlayerPedId(), v, false)
                    NetworkConcealPlayer(NetworkGetPlayerIndexFromPed(v), true, 1)
                end
            end
        end
        for v in EnumeratePeds() do
            if v ~= PlayerPedId() then
                ResetEntityAlpha(v)
                SetEntityNoCollisionEntity(v, PlayerPedId(), true)
                NetworkConcealPlayer(NetworkGetPlayerIndexFromPed(v), false, 1)
            end
        end
    end)--]]

    Wait(2000)
    trace("Calling music player...")
    PlayUrl("MAIN", "https://youtu.be/vT7f8pQcgR0", 0.25, true)
    trace("Battle Royal->[NUI]->Music player = OK")

    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do Citizen.Wait(1) end
    SetEntityCoords(PlayerPedId(), -26.70, -92.71, 56.25, 0,0,0,0)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_AA_COFFEE", -1, false)
    FreezeEntityPosition(PlayerPedId(), 1)
    SetEntityHeading(PlayerPedId(), 82.30)
    
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
    
    RMenu.Add('arrival', "arrival_main", RageUI.CreateMenu("Battle Royal", "~r~Par Pablo Z. ~o~v1.0"))
    RMenu:Get("arrival", "arrival_main").Closed = function()end
    RMenu:Get("arrival", "arrival_main").Closable = false

    RageUI.Visible(RMenu:Get("arrival",'arrival_main'), true)

    Citizen.CreateThread(function()
        while playerState == 0 do
            RageUI.IsVisible(RMenu:Get("arrival",'arrival_main'),true,true,true,function()
                RageUI.ButtonWithStyle("Jouer",nil, {RightLabel = "→→"}, true, function(_,_,s)
                end)
                RageUI.ButtonWithStyle("Boutique",nil, {RightLabel = "→→"}, true, function(_,_,s) 
                end)
            end, function()    
            end, 1)
        end
    end)
    

end