# input remap per process
 this is a very simple service, it remaps inputs on a per app basis,
 if the service is running, and the target app opens, the remap is applied.
## Dependencies
THIS RELIES ON BEING RAN IN AN XORG ENVIRONMENT
IF IT'S WAYLAND, FIND YOUR OWN FRIGGIN TOOLING
- xdotool
- xbindkeys
- inotify-tools

## Install

### Creating a Config File
- config is expected to live under:
```bash
$HOME/.config/mouse-remap.conf
```
- config example:
```conf
[RuneLite]
match = net.runelite.client.RuneLite
mappings = b:3=Escape, b:4=space
```
- where *match* is the _case sensitive process name_
- where *b:x* is the mouse button number you wish to target
- where *b:x=\<key\>* is the key you wish to remap to.
- keyboard combos can be mapped as well, using the following:
```conf
[RuneLite]
match = net.runelite.client.RuneLite
mappings = b:8=Escape, b:9=space, Control+q=F12
```
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


