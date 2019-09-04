#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
    rollerShutterAction(topic, payload)

Open and close roller shutters.
"""
function rollerShutterAction(topic, payload)

    # log:
    #
    Snips.printLog("action rollerShutterAction() started.")

    # find the device and room:
    #
    slots = extractSlots(payload)
    Snips.printDebug(slots)

    # ignore intent if it is not a shutter!
    #
    if  slots == nothing || slots[:device] == nothing
        Snips.printLog("No device found in intent.")
        return true
    end

    if !(slots[:action] in ["open", "close"])
        Snips.publishEndSession(:dunno)
        return true
    end

    # get matched devices from config.ini and find correct one:
    #
    matchedDevices = getDevicesFromConfig(slots)
    return true
end



function extractSlots(payload)

    slots = Dict()
    slots[:room] = Snips.extractSlotValue(payload, SLOT_ROOM)
    if slots[:room] == nothing
        slots[:room] = Snips.getSiteId()
    end

    slots[:deviceName] = Snips.extractSlotValue(payload, SLOT_DEVICE)
    slots[:action] = Snips.extractSlotValue(payload, SLOT_ACTION)

    slots[:percent] = Snips.extractSlotValue(payload, SLOT_PERCENT)
    if slots[:percent] == nothing
        slots[:partly] = Snips.extractSlotValue(payload, SLOT_PARTLY)
        if slots[:partly] != nothing
            if slots[:partly] == "almost"
                slots[:percent] = 90
            elseif slots[:partly] == "threeQuarter"
                slots[:percent] = 75
            elseif slots[:partly] == "half"
                slots[:percent] = 50
            end
        end
    end

    return slots
end




function getDevicesFromConfig(slots)

    devices = Snips.getConfig(INI_DEVICES, multiple = true)
    Snips.printDebug(devices)
    Snips.printDebug(slots)


    matchedDevices = []
    # add all devices in house:
    #
    if slots[:deviceName] == "all" && slots[:room] == "house"
        matchedDevices = devices

    # add all devices in room:
    #
    elseif slots[:deviceName] == "all"
        for d in devices
            room = Snips.getConfig(INI_ROOM, onePrefix = d)
            if  room == slots[:room]
                push!(matchedDevices, d)
            end
        end
    # only device with matching name:
    #
    else
        for d in devices
            room = Snips.getConfig(INI_ROOM, onePrefix = d)
            name = Snips.getConfig(INI_NAME, onePrefix = d)
            if  room == slots[:room] && name == slots[:deviceName]
                push!(matchedDevices, d)
            end
        end
    end
    Snips.printDebug(matchedDevices)

    return matchedDevices
end
