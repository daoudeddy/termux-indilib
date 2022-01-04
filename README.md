# Run INDI Lib on Termux

## Note
Root is required to run indiserver with drivers

## Installation
```bash
git clone https://github.com/daoudeddy/termux-indilib.git
cd termux-indilib
chmod +x install.sh
./install.sh
```

## Udev rules
Android does not support udev rules, you need to execute them manually

Set the memory limit for usbfs
```bash
pkg in tsu
sudo echo 200 > /sys/module/usbcore/parameters/usbfs_memory_mb
```

## 3rd Party drivers support
Driver | Supported | Tested | Working
--- | --- | --- | --- 
StarLight Xpress | no | no | no
Install MaxDomeII | yes | no | no 
NexDome | yes | no | no 
Spectracyber | yes | no | no 
AAG Cloud Watcher | yes | no | no 
Moravian | yes | no | no 
FLI Driver | yes | no | no 
SBIG | yes | no | no 
i.Nova PLx | no | no | no 
Apogee | yes | no | no 
Point Grey FireFly MV | no | no | no 
QHY | yes | no | no 
GPhoto | yes | yes | yes 
QSI | yes | no | no 
Ariduino | yes | no | no 
Fishcamp | yes | no | no 
GPSD | no | no | no 
GiGE machine vision | yes | no | no 
Meade DSI | yes | no | no 
ZWO Optics ASI | no | no | no 
MGen Autoguide | no | no | no 
Astromechanics Focuser | yes | no | no 
RadioSim Receiver | yes | no | no 
LIME-SDR Receiver | no | no | no 
GPS NMEA | no | no | no 
RTKLIB | no | no | no 
Armadillo & Platypus | yes | no | no 
Nightscape 8300 | yes | no | no 
Atik | no | no | no 
Toupbase | no | no | no 
DreamFocuser | yes | no | no 
Avalon StarGO | yes | no | no 
Bee Focuser | yes | no | no 
Shelyak Spectrograph | yes | no | no 
AOK SkyWalker Mount | yes | no | no 
Talon6 Mount | yes | no | no 
Pentax | no | no | no 
AstroLink4 | no | no | no 
AHP XC Correlators | no | no | no 
Orion StarShoot G3 | yes | no | no 
SV305 Camera | no | no | no 
Bresser Exos 2 GoTo Mount | yes | no | no 
Player One Astronomy's Camera | no | no | no 

## How does it work?
There's a patch file included in this repo with the needed changes to makes work

## Links
[Termux](https://termux.com)

[INDI Libray](https://indilib.org)
