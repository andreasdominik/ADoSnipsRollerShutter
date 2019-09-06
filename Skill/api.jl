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

    end
end


"""
Only close to perc percent if clouds are < limit and > 1h before sunset
"""
function doSunshield(device, clouds)

    ip = Snips.getConfig(INI_IP, onePrefix = device)
    perc = tryparse(Int, Snips.getConfig(INI_SUN_SHIELD, onePrefix = device))
    perc == nothing && perc = 15
    weather = Snips.getOpenWeather()

    # open if sunset is coming soon:
    #
    if weather != nothing && weather[:sunset] < (Dates.now() + Dates.Hour(1))
        Snips.moveShelly25roller(ip, :open)

    # open if clody and close if sunny:
    #
    elseif weather != nothing && weather[:clouds] != nothing &&
           weather[:clouds] > clouds
        Snips.moveShelly25roller(ip, :open)
    else
        Snips.moveShelly25roller(ip, :go_to, pos = perc)
    end
end





function shuttersInRoom(room)

    devices = []
    if room == "house"
        append!(devices, Snips.getConfig(INI_DEVICES))

    else
        for d in Snips.getConfig(INI_DEVICES)
            Snips.setConfigPrefix(d)
            if Snips.getConfig(INI_ROOM) == room
                push!(devices, d)
            end
        end
    end
    return devices
end
