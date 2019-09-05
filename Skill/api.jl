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
