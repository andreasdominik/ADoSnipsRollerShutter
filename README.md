# ADoSnipsTemplate

This is a template skill for the SnipsHermesQnD framework for Snips.ai
written in Julia.

 The full documentation is just work-in-progress!
 Current version can be visited here:

 [Framework Documentation](https://andreasdominik.github.io/ADoSnipsQnD/dev)

## Skill

The skill makes it possible to open and close roller shutters.

##### Hardware

Shelly2.5 WiFi switches are supported via the QnD framework (they can be
set up and used Snips-like without using a cloud service).

Each device can be opened or closed or moved to a percent value or
a fraction (such as *almost closed* or *half closed*) as defined in the
respective intent (rollerUpDownDE).



## `config.ini`

The configuration includes definition of devices and
configuration of each device (see example `config.ini`):
```
devices=garden_window,lanay

# roller shutter to lanay:
#
garden_window:room=default
garden_window:name=big,garden
garden_window:comment=the door to the lanay
garden_window:driver=shelly25
garden_window:sunshield=15
garden_window:ip=192.168.0.201
```
##### Paremeters:

**devices:**
list of arbitrary but unique device names. Foe each device name the
configuration must be given.

**room:**
siteId of the device

**name:**
list of names to which the device will react. The names must correspond
with the value of the slot ado/shutterdevice in the intent

**comment:**
name of the roller shutter to be used for the voice feedback by Snips

**driver:**
only Shelly25 is supported at the moment

**sunshield:**
percent open of the sunshield setting. The trigger command `sunshield`
will close to this value only if
- it is sunny (< 75% cloud coverage)
- it is > 1h before sunset.

The sunshield function will only be availible if access to openweather.org
is configured in the framework.

**ip:**
ip address or DNS name of the Shelly2.5 switch.





# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/
