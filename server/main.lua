local conf = {
    maxP = 1,
    minP = 1
}

function trace(msg)
    print("^1[Pablo's BR] ^7"..msg)
end

local players = {}

local gameState = 0




RegisterNetEvent("p_br:requestLobbyInfos")
AddEventHandler("p_br:requestLobbyInfos", function()
    local _src = source
    TriggerClientEvent("p_br:callbackLobbyInfos", _src, {max = conf.maxP, min = conf.minP, actual = #players, sID = 1})
end)
countfrom = 0

RegisterNetEvent("p_br:requestGameState")
AddEventHandler("p_br:requestGameState", function()
    local _src = source
    local tot = 0
    for k,v in pairs(players) do tot = tot + 1 end
    TriggerClientEvent("p_br:cbGameState", _src, gameState, tot, countfrom)
end)

RegisterNetEvent("p_br:connected")
AddEventHandler("p_br:connected", function()
    local _src = source
    if players[_src] then return end
    trace("Player ^3"..GetPlayerName(_src).." ^2connected ^7and ^2joined lobby ^7!") 
    players[_src] = {name = GetPlayerName(_src)}

    local total = 0

    for k,v in pairs(players) do total = total + 1 end
    if gameState == 0 then 
        TriggerClientEvent("p_br:callbackLobbyInfos", -1, {max = conf.maxP, min = conf.minP, actual = total, sID = 1})
        Citizen.SetTimeout(1000, function()
            if total >= conf.minP then
                if gameState == 1 then return end
                gameState = 1
                TriggerClientEvent("p_br:launch", -1, total)
                countfrom = 80
                Citizen.CreateThread(function()
                    while gameState == 1 do
                        Citizen.Wait(1000)
                        countfrom = countfrom - 1
                        if countfrom <= 0 then
                            TriggerClientEvent("p_br:drop", -1)
                            gameState = 2
                        end
                    end
                end)
            end
        end)
    end
end)

AddEventHandler('playerDropped', function (reason)
    local _src = source

    if not players[_src] then 
        trace("Player ^3"..GetPlayerName(_src).." ^1disconnected^7: ^3"..reason.."^7") 
        return 
    end
    players[_src] = nil 

    local total = 0

    for k,v in pairs(players) do total = total + 1 end
    if gameState == 0 then 
        TriggerClientEvent("p_br:callbackLobbyInfos", -1, {max = conf.maxP, min = conf.minP, actual = total, sID = 1})
    end
    trace("Player ^3"..GetPlayerName(_src).." ^1disconnected^7 and was a player: ^3"..reason.."^7") 
    
  end)



