#
# API function goes here, to be called by the
# skill-actions:
#

function doMove(device, slots)

    ip = Snips.getConfig(INI_IP, onePrefix = device)

    if slots[:percent] isa Int
        Snips.moveShelly25roller(ip, :go_to, pos = slots[:percent])

    elseif slots[:action] == "open"
        Snips.moveShelly25roller(ip, :open)

    elseif slots[:action] == "close"
        Snips.moveShelly25roller(ip, :close)

    elseif slots[:action] == "sunshield"
        doSunshield(device)
    end
end


"""
Only close to perc percent if clouds are < limit and > 1h before sunset
"""
function doSunshield(device)

    ip = Snips.getConfig(INI_IP, onePrefix = device)
    sunsetMinutes = Snips.getConfig(INI_SUNSET)
    cloudLimit = tryparse(Int, Snips.getConfig(INI_CLOUD_LIMIT))
    if cloudLimit == nothing
        cloudLimit = 80
    end

    perc = tryparse(Int, Snips.getConfig(INI_SUN_SHIELD, onePrefix = device))
    if perc == nothing
        perc = 15
    end

    weather = Snips.getWeather()

    if weather == nothing
        Snips.printLog("closing sun shield beacuse of missing weather information.")
        Snips.moveShelly25roller(ip, :to_pos, pos = perc)

    # open if sunset is coming soon:
    #
    elseif weather[:sunset] != nothing &&
           weather[:sunset] < Dates.now() + Dates.Minute(sunsetMinutes)
        Snips.printLog("opening sun shield beacuse of sunset.")
        Snips.moveShelly25roller(ip, :open)

    # open if cloudy and close if sunny:
    #
    elseif weather[:clouds] != nothing && weather[:clouds] >= cloudLimit
        Snips.printLog("opening sun shield because of clouds.")
        Snips.moveShelly25roller(ip, :open)

    else
        Snips.printLog("closing sun shield beacuse of sun.")
        Snips.moveShelly25roller(ip, :to_pos, pos = perc)
    end
end
# function doSunshield(device)
#
#     ip = Snips.getConfig(INI_IP, onePrefix = device)
#     sunsetMinutes = Snips.getConfig(INI_SUNSET)
#     cloudLimit = Snips.getConfig(INI_CLOUD_LIMIT)
#
#     perc = tryparse(Int, Snips.getConfig(INI_SUN_SHIELD, onePrefix = device))
#     if perc == nothing
#         perc = 15
#     end
#     weather = Snips.getWeather()
#
#     if weather == nothing
#         Snips.printLog("closing sun shield beacuse of missing weather information.")
#         Snips.moveShelly25roller(ip, :to_pos, pos = perc)
#
#     # open if sunset is coming soon:
#     #
#     elseif weather[:sunset] < Dates.now() + Dates.Minute(sunsetMinutes)
#         Snips.printLog("opening sun shield beacuse of sunset.")
#         Snips.moveShelly25roller(ip, :open)
#
#     # open if cloudy and close if sunny:
#     #
#     elseif weather[:clouds] != nothing && weather[:clouds] >= cloudLimit
#         Snips.printLog("opening sun shield because of clouds.")
#         Snips.moveShelly25roller(ip, :open)
#
#     else
#         Snips.printLog("closing sun shield beacuse of sun.")
#         Snips.moveShelly25roller(ip, :to_pos, pos = perc)
#     end
# end





function shuttersInRoom(room)

    devices = []
    if room == "house"
        append!(devices, Snips.getConfig(INI_DEVICES, multiple = true))

    else
        iniDevices = Snips.getConfig(INI_DEVICES, multiple = true)
        Snips.printDebug(iniDevices)
        for d in iniDevices
            Snips.setConfigPrefix(d)
            if Snips.getConfig(INI_ROOM) == room
                push!(devices, d)
            end
            Snips.resetConfigPrefix()
        end
    end
    return devices
end
