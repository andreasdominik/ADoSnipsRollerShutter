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
    if  slots == nothing || slots[:deviceName] == nothing
        Snips.printLog("No device found in intent.")
        return true
    end

    if !(slots[:action] in ["open", "close", "sunshield"])
        Snips.publishEndSession(:dunno)
        return true
    end

    # get matched devices from config.ini and find correct one:
    #
    matchedDevices = getDevicesFromConfig(slots)
    Snips.printDebug("matched: $matchedDevices")

    # move shutters:
    #
    if length(matchedDevices) < 1
        Snips.publishEndSession(:no_matched_shutter)
        return true
    else
        Snips.publishEndSession("")
        if slots[:action] == "open"
            actionText = Snips.langText(:i_open)
        elseif slots[:action] == "sunshield"
            actionText = Snips.langText(:i_sunshield)
        else
            actionText = Snips.langText(:i_close)
        end

        for d in matchedDevices
            Snips.printDebug("Try device $d")
            if checkConfig(d)
                comment = Snips.getConfig("comment", onePrefix = d)
                Snips.printDebug("config checked for $d, $comment")
                Snips.publishSay("$actionText $(Snips.langText(:roller_shutter)) $comment")
                doMove(d, slots)
            else
                Snips.publishSay("$(Snips.langText(:error_ini)) $d")
            end
        end
    end

    return true
end



function extractSlots(payload)

    slots = Dict()
    slots[:room] = Snips.extractSlotValue(payload, SLOT_ROOM)
    if slots[:room] == nothing
        slots[:room] = Snips.getSiteId()
    end

    slots[:deviceName] = Snips.extractSlotValue(payload, SLOT_DEVICE)
    if slots[:deviceName] == nothing
        slots[:deviceName] = "any"
    end

    slots[:action] = Snips.extractSlotValue(payload, SLOT_ACTION)

    try
        slots[:percent] = tryparse(Int, Snips.extractSlotValue(payload, SLOT_PERCENT))
    catch
        slots[:percent] = nothing
    end
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



"""
    triggerRollerShutter(topic, payload)

The trigger must have the following JSON format:
```
    {
      "target" : "qnd/trigger/andreasdominik:ADoSnipsRollerShutter",
      "origin" : "ADoSnipsScheduler",
      "sessionId": "1234567890abcdef",
      "siteId" : "default",
      "time" : "timeString",
      "trigger" : {
        "device" : "small_lanay",
        "action" : "open"
      }
    }
```
Commands "open" or "close" or "sunshield" will be executed with the api.
`device` is unique device name defined in `config.ini`
"""
function triggerRollerShutter(topic, payload)

    Snips.printLog("action triggerRollerShutter() started.")
    Snips.printDebug("Trigger: $payload")

    # test if trigger is complete:
    #
    payload isa Dict || return false
    haskey( payload, :trigger) || return false
    trigger = payload[:trigger]

    haskey(trigger, :action) || return false
    trigger[:action] isa AbstractString || return false
    command = trigger[:action]
    command in ["open", "close", "sunshield"] || return false

    # re-read the config.ini (in case params have changed):
    #
    Snips.readConfig("$APP_DIR")

    # get device params from config.ini:
    #
    if !checkConfig(trigger[:device])
        Snips.printLog("ERROR: Cannot read config values for triggerRollerShutter!")
        return false
    end

    if command == "close"
        Snips.printLog("closing roller shutter $(trigger[:device])")
        doMove(trigger[:device], Dict(:action => "close", :percent => nothing))
    elseif command == "sunshield"
        Snips.printLog("sun shield for roller shutter $(trigger[:device])")
        doSunshield(trigger[:device])
    else
        Snips.printLog("opening roller shutter $(trigger[:device])")
        doMove(trigger[:device], Dict(:action => "open", :percent => nothing))
    end
    return false
end




function getDevicesFromConfig(slots)

    devices = Snips.getConfig(INI_DEVICES, multiple = true)
    if devices == nothing
        devices = ["no devices found in config"]
    end
    if slots == nothing
        slots == "no slots in payloud"
    end
    Snips.printDebug("config.ini: $devices")
    Snips.printDebug("slots: $slots")


    matchedDevices = []
    # if there is only one shutter in the room, use this:
    #
    inRoom = shuttersInRoom(slots[:room])
    Snips.printDebug("inRoom: $inRoom")

    if length(inRoom) == 1
        push!(matchedDevices, inRoom[1])

    # add all devices in house:
    #
    elseif slots[:deviceName] == "all" && slots[:room] == "house"
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
        for d in inRoom
            names = Snips.getConfig(INI_NAME, onePrefix = d, multiple = true)
            Snips.printDebug("iterate in Room: $d, $names")
            if  slots[:deviceName] in names
                push!(matchedDevices, d)
            end
        end
    end
    Snips.printDebug(matchedDevices)

    return matchedDevices
end



function checkConfig(d)

    # entries for device:
    #
    Snips.setConfigPrefix(d)
    success  = Snips.isConfigValid(INI_ROOM) &&
           Snips.isConfigValid(INI_NAME) &&
           Snips.isConfigValid(INI_COMMENT) &&
           Snips.isConfigValid(INI_DRIVER, regex = r"shelly25") &&
           Snips.isConfigValid(INI_SUN_SHIELD, regex = r"^\d+$") &&
           Snips.isConfigValid(INI_IP, regex = r"\d+\.\d+\.\d+\.\d+")


    # global entries:
    #
    Snips.resetConfigPrefix()
    success = success &&
              Snips.isConfigValid(INI_SUNSET, regex = r"^\d+$") &&
              Snips.isConfigValid(INI_CLOUD_LIMIT, regex = r"^\d+$")
    return success
end
