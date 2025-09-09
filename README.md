# input remap per application

this is a very simple service, it remaps inputs on a per app basis,
 if the service is running, and the target app opens, the remap is applied.

this does not check if a window is focussed, so it _will_ cause clashes and odd
behaviour, if duplicate binds are used.
_______________

## Dependencies

### XORG environments
- xdotool
- xbindkeys
- inotify-tools

### Wayland environments
[wez/evremap](https://github.com/wez/evremap)
#### **> [!IMPORTANT]
> [!warning] PERMISSIONS
> This service expects the user to have followed the evremap install guide,
choosing to add the user to the input group - granting permissions to apply remaps.
_______________

## Install

### Creating a Config File

- config is expected to live under:
```bash
$HOME/.config/mouse-remap.conf
```

#### X11 configs
- config example:
```conf
[RuneLite]
match = net.runelite.client.RuneLite
mappings = b:3=Escape, b:4=space, Control+q=F12
```
- where *match* is the _case sensitive process name_
- where *b:x* is the **mouse** button number you wish to target
- where *b:x=\<key\>* is the key you wish to remap to.
- where *Control+q* is the key combination you wish to map.

#### Wayland configs
- config example:
```conf
[RuneLite]
match = net.runelite.client.RuneLite
mappings = BTN_SIDE=KEY_SPACE, BTN_EXTRA=KEY_ESC
device = SteelSeries SteelSeries Rival 3
```
- where *match* is the _case sensitive process name_
- where *BTN_\<key\>* is the **mouse** button number you wish to target
- where *BTN_\<key\>=\<key\>* is the key you wish to remap to.
- where *device = <device name here>* is the device found in the list-devices subcommand of evremap.
- for wayland environments, the keys are a bit different. In order to find them,
do the following:
-    ```evremap list-devices``` - this will list all available HIDs
-    ```evremap list-keys``` - this will list all the available keys that evremap supports.
_______________

### Systemd Service

the provided mouse-remap.service expects to be placed:
```bash
$HOME/.config/systemd/user/mouse-remap.service
```
this is so systemd will recognise this as a user service.

the example given expects the actual daemon script to be placed under:
```bash
$HOME/.local/bin/mouse_remap_daemon.sh
```
if you want the daemon script somewhere else, edit the ExecStart var.
if you want to change the config location, assign the env. var. ```CONFIG=path/to/your/config```
in the ExecStart var.
### Daemon Script

as mentioned previously, the expected 'out-the-box' install location is:

```bash
$HOME/.local/bin/mouse_remap_daemon.sh
```

- you may have to make it executable, do so with:
```bash
chmod +x mouse_remap_daemon.sh
```
### Enabling and Starting the service
to enable and start the service immediately, run the following:
```bash
systemctl --user enable --now mouse-remap.service
```

# Verifying it works
## button maps
### using xev
run the following:
```bash
xev | grep button
```
- this opens a xev window, hit buttons and see if they work. pretty simple.

### using xinput
find the mouse device:
```bash
xinput list
```
- find your device, note the ID.

run:
```bash
xinput test <id-goes-here>
```

mash mouse buttons, should see:
```
button press   x
button release x
```

adjust config accordingly.

### using libinput
this will start a debug process, where each button press/pointer motion will be printed in STDOUT.
use this to determine the button names of the keys you wish to remap.

```bash
libinput debug-events
```

## process ID

check the name you've used in your config with pgrep.
example:
```bash
pgrep -x RuneLite
```
if a PID is returned, it works, otherwise, you need to find the exact name.
example:
```bash
ps aux | grep -i runelite
```
in this case, I found:
```net.runelite.client.RuneLite```

so my config is as follows:
```conf
...
[RuneLite]
match = net.runelite.client.RuneLite
...
```

## Debugging

if you run this as a foreground service, by just running the script manually,
the logs will be printed to STDOUT.

to enable debug messaging, run it with
```bash

DEBUG=1
```

you can also run pgrep against xbindkeys:
```bash
pgrep -a xbindkeys
```
you should see a binding like so:
```bash
xbindkeys -f /tmp/mouse_remap/<App name>.scm
```


