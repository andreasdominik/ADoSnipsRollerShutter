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
    Snips.printLog("action rollerShutterAction() started.")

    # get my name from config.ini:
    #
    myName = Snips.getConfig(INI_MY_NAME)
    if myName == nothing
        Snips.publishEndSession(:noname)
        return false
    end

    # get the word to repeat from slot:
    #
    word = Snips.extractSlotValue(payload, SLOT_WORD)
    if word == nothing
        Snips.publishEndSession(:dunno)
        return true
    end

    # say who you are:
    #
    Snips.publishSay(:bravo)
    Snips.publishEndSession("""$(Snips.langText(:iam)) $myName.
                            $(Snips.langText(:isay)) $word""")
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
