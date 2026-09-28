local ESX = exports['es_extended']:getSharedObject()

-- Function to get player radio data
local function getPlayerRadioData(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.identifier
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_radio WHERE player_id = @player_id', {['@player_id'] = identifier})
        if result[1] then
            return result[1]
        else
            MySQL.Sync.execute('INSERT INTO player_radio (player_id, channel_id, volume) VALUES (@player_id, @channel_id, @volume)', {
                ['@player_id'] = identifier,
                ['@channel_id'] = Config.DefaultChannel,
                ['@volume'] = Config.DefaultVolume
            })
            return {player_id = identifier, channel_id = Config.DefaultChannel, volume = Config.DefaultVolume}
        end
    end
end

-- Event to change the radio channel
RegisterNetEvent('radio:changeChannel')
AddEventHandler('radio:changeChannel', function(channel)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.identifier
        MySQL.Sync.execute('UPDATE player_radio SET channel_id = @channel_id WHERE player_id = @player_id', {
            ['@player_id'] = identifier,
            ['@channel_id'] = channel
        })
        TriggerClientEvent('radio:updateChannel', playerId, channel)
    end
end)

-- Event to change the radio volume
RegisterNetEvent('radio:changeVolume')
AddEventHandler('radio:changeVolume', function(volume)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.identifier
        MySQL.Sync.execute('UPDATE player_radio SET volume = @volume WHERE player_id = @player_id', {
            ['@player_id'] = identifier,
            ['@volume'] = volume
        })
        TriggerClientEvent('radio:updateVolume', playerId, volume)
    end
end)

-- Event to send a radio message
RegisterNetEvent('radio:sendMessage')
AddEventHandler('radio:sendMessage', function(message)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.identifier
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_radio WHERE player_id = @player_id', {['@player_id'] = identifier})
        if result[1] then
            local channel = result[1].channel_id
            local players = MySQL.Sync.fetchAll('SELECT player_id FROM player_radio WHERE channel_id = @channel_id', {['@channel_id'] = channel})
            for i, player in ipairs(players) do
                local targetPlayerId = ESX.GetPlayerFromIdentifier(player.player_id).source
                if targetPlayerId then
                    TriggerClientEvent('radio:receiveMessage', targetPlayerId, playerId, message)
                end
            end
        end
    end
end)

-- Player loaded event
AddEventHandler('esx:playerLoaded', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local radioData = getPlayerRadioData(playerId)
        if radioData then
            TriggerClientEvent('radio:updateChannel', playerId, radioData.channel_id)
            TriggerClientEvent('radio:updateVolume', playerId, radioData.volume)
        end
    end
end)