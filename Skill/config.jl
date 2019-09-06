
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#

lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_ROOM = "Room"
const SLOT_DEVICE = "DeviceName"
const SLOT_ACTION = "Action"
const SLOT_PERCENT = "percentClosed"
const SLOT_PARTLY = "partlyClosed"

# name of entry in config.ini:
#
const INI_DEVICES = "devices"
const INI_ROOM = "room"
const INI_NAME = "name"
const INI_COMMENT = "comment"
const INI_DRIVER = "driver"
const INI_SUN_SHIELD = "sun_shield"
const INI_IP = "ip"

# shield the sun only if less then 75 perc clouds:
#
const SUNSHIELD_CLUUD_LIMIT = 75


#
# link between actions and intents:
# intent is linked to action{Funktion}
# the action is only matched, if
#   * intentname matches and
#   * if the siteId matches, if site is  defined in config.ini
#     (such as: "switch TV in room abc").
#
# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("rollerUpDownDE", rollerShutterAction)
else
    Snips.registerIntentAction("rollerUpDownDE", rollerShutterAction)
end
Snips.registerTriggerAction("ADoSnipsRollerShutter", triggerRollerShutter)
