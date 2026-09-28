local ESX = exports['es_extended']:getSharedObject()

local currentChannel = Config.DefaultChannel
local currentVolume = Config.DefaultVolume

-- Function to open the radio UI
local function openRadioUI()
    local elements = {}
    
    for i, channel in ipairs(Config.RadioChannels) do
        table.insert(elements, {label = channel.name, value = i})
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'radio_menu', {
        title = 'Radio',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        currentChannel = data.current.value
        TriggerServerEvent('radio:changeChannel', currentChannel)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

-- Function to change the radio volume
local function changeVolume(volume)
    currentVolume = math.max(Config.MinVolume, math.min(Config.MaxVolume, volume))
    TriggerServerEvent('radio:changeVolume', currentVolume)
end

-- Register command to open the radio UI
RegisterCommand('radio', function()
    openRadioUI()
end, false)

-- Register keybind to open the radio UI
RegisterKeyMapping('radio', 'Open Radio', 'keyboard', 'F10')

-- Event to receive radio messages
RegisterNetEvent('radio:receiveMessage')
AddEventHandler('radio:receiveMessage', function(sender, message)
    local playerId = GetPlayerServerId(PlayerId())
    if playerId ~= sender then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {'[Radio] ' .. GetPlayerName(sender), message}
        })
    end
end)

-- Event to update the radio channel
RegisterNetEvent('radio:updateChannel')
AddEventHandler('radio:updateChannel', function(channel)
    currentChannel = channel
end)

-- Event to update the radio volume
RegisterNetEvent('radio:updateVolume')
AddEventHandler('radio:updateVolume', function(volume)
    currentVolume = volume
end)