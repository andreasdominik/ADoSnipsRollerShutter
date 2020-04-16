# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

#
# language settings:
# Snips.LANG in QnD(Snips) is defined from susi.toml or set
# to "en" if no susi.toml found.
# This will override LANG by config.ini if a key "language"
# is defined locally:
#
if Snips.isConfigValid(:language)
    Snips.setLanguage(Snips.getConfig(:language))
end
# or LANG can be set manually here:
# Snips.setLanguage("fr")
#
# set a local const with LANG:
#
const LANG = Snips.getLanguage()
#
# END OF DO-NOT-CHANGE.

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
const INI_SUN_SHIELD = "sunshield"
const INI_IP = "ip"

# shield the sun only if less then 75 perc clouds:
#
const SUNSHIELD_CLOUD_LIMIT = 80


#
# link between actions and intents:
# intent is linked to action{Funktion}
# the action is only matched, if
#   * intentname matches and
#   * if the siteId matches, if site is  defined in config.ini
#     (such as: "switch TV in room abc").
#
Snips.registerIntentAction("rollerUpDown", rollerShutterAction)
Snips.registerTriggerAction("ADoSnipsRollerShutter", triggerRollerShutter)
