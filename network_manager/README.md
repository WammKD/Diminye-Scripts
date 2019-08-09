A simple shell command to update the timezone. Requires password.

If you want to run every time network manager brings up a network, copy this file to `/usr/local/bin`.

In order to have it run without needing a password, enter `sudo visudo` and add this line to the end of the file: `ALL ALL=(root) NOPASSWD: /usr/local/bin/tz-update`.

Then create a file for Network Manager so that it runs `tz-update`:
`echo '[ "$2" = "up" ] && sudo tz-update &' | sudo tee /etc/NetworkManager/dispatcher.d/99-tzupdate`
`sudo chmod +x /etc/NetworkManager/dispatcher.d/99-tzupdate`

And you're all set.