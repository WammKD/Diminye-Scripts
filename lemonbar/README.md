Move each file, except for `98-lemon_wifi`, to `/usr/local/bin` and run `lemon.sh`.

Move `98-lemon_wifi` to `/etc/NetworkManager/dispatcher.d/` in order for the network name to be updated immediately, upon activating a new network.

In order to adjust the brightness of the monitor, run `sudo visudo` and add this line to the end of the file: `ALL ALL=(root) NOPASSWD: /usr/local/bin/lemon_brightness.sh`. Then attach the desired keys to run `lemon_brightness.sh [+|-]`.