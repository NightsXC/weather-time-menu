local clockTime = {
    hours = 12,
    minutes = 0
}

local freezeTime = true

local freezeWeather = true

CreateThread(function()
    SetWeatherOwnedByNetwork(true)
    SetWeatherTypeNowPersist('CLEAR')

    while freezeTime do -- Fryser kun tidspunktet hvis freezeTime er true
        Wait(1000) -- Opdatere tiden hver sekund da andet er overdrivelse

        -- Sørger for at hours/minutes/seconds ikke har en value som vil crashe spillet
        if clockTime.hours > 23 then
            clockTime.hours = 12
        end
        if clockTime.minutes > 59 then
            clockTime.minutes = 0
        end

        NetworkOverrideClockTime(clockTime.hours, clockTime.minutes, 0) -- Sætter tidspunktet ingame
    end
end)


RegisterNetEvent("setTime", function()
    local result = lib.inputDialog("Sæt tiden", {
        {
            type = 'number',
            min = 0,
            max = 23,
            label = 'Hour'
        },
        {
            type = 'number',
            min = 0,
            max = 59,
            default = 0,
            label = 'Minute'
        }
    })

    if not result then return end

    clockTime.hours = result[1]
    clockTime.minutes = result[2]

    NetworkOverrideClockTime(clockTime.hours, clockTime.minutes, 0)

    lib.showContext('weather-time-menu')
end)

RegisterNetEvent("setWeather", function(id)
    SetWeatherTypeNowPersist(id)
    if id == 'SNOW' or id == 'XMAS' or id == 'SNOW_HALLOWEEN' then
        SetSnowLevel(2)
        ForceSnowPass(true)
    elseif id == 'SNOWLIGHT' then
        SetSnowLevel(1)
        ForceSnowPass(true)
    elseif id == 'BLIZZARD' then
        SetSnowLevel(3)
    else
        SetSnowLevel(0)
        ForceSnowPass(false)
    end
    lib.showContext('weatherMenu')
end)

RegisterNetEvent("freezeTime", function()
    if freezeTime == true then
        freezeTime = false
    else
        freezeTime = true
    end
end)



local weatherTypes = {
    ['CLEAR'] = 'Clear',
    ['EXTRASUNNY'] = 'Extra Sunny',
    ['CLOUDS'] = 'Clouds',
    ['OVERCAST'] = 'Overcast',
    ['RAIN'] = 'Rain',
    ['THUNDER'] = 'Thunder',
    ['SMOG'] = 'Smog',
    ['FOGGY'] = 'Foggy',
    ['XMAS'] = 'Xmas',
    ['SNOW'] = 'Snow',
    ['SNOWLIGHT'] = 'Snow Light',
    ['BLIZZARD'] = 'Blizzard',
    ['HALLOWEEN'] = 'Halloween',
    ['NEUTRAL'] = 'Neutral',
    ['RAIN_HALLOWEEN'] = 'Rain Halloween',
    ['SNOW_HALLOWEEN'] = 'Snow Halloween'
}

RegisterCommand('weather-time-menu', function()
    local freezeTimeString = 'False'
    if freezeTime then freezeTimeString = 'True' end
    local freezeWeatherString = 'False'
    if freezeWeather then freezeWeatherString = 'True' end

    local weatherOptions = {}

    for id, label in pairs(weatherTypes) do
        table.insert(weatherOptions, {
            title = label,
            event = 'setWeather',
            args = id
        })
    end

    lib.registerContext({
        id = 'weatherMenu',
        title = 'Vejr Menu',
        menu = 'weather-time-menu',
        options = weatherOptions
    })

    lib.registerContext({
        id = 'weather-time-menu',
        title = 'Vejr og Tid',
        options = {
            {
                title = 'Sæt tid',
                description = 'Sæt tiden det skal blive (Kun for dig)',
                event = 'setTime',
            },
            {
                title = 'Sæt Vejr',
                description = 'Sæt Vejret det skal blive (Kun for dig)',
                menu = 'weatherMenu'
            },
            {
                progress = 100,
                colorScheme = "gray.2",
                readOnly = true
            },
            {
                title = 'Frys Tid [' .. freezeTimeString .. ']',
                description = 'Frys tiden så det ikke ændrer sig',
                event = 'freezeTime'
            },
            {
                title = 'Frys Vejr [' .. freezeWeatherString .. '] (Virker ikke nu)',
                description = 'Frys vejret så det ikke ændre sig'
            }
        }
    })

    lib.showContext('weather-time-menu')

end)