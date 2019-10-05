# Deklanche (Aerosnap in BASH)

While the script will work for spaced out commands, rapid usage might result in unruly behavior/experience.

Setting up a FIFO (pipe) and a simple bash/dash "daemon" to read the pipe and call `deklanche` whenever anything from the pipe is read can ensure that commands are read in the correct order, regardless of how quickly the commands are given.

If you have a place to put commands at startup, you can create this daemon in the `/tmp` directory and start it at startup with something as simple as

```bash
mkdir /tmp/deklanche.d                                                                              &&
echo "while true; do deklanche \$(cat < /tmp/deklanche.d/pipe); done" > /tmp/deklanche.d/deklanched &&
mkfifo /tmp/deklanche.d/pipe                                                                        &&
dash /tmp/deklanche.d/deklanched &
```

You can then run commands to `deklanche` by doing something like `echo --left > /tmp/deklanche.d/pipe` or `echo --up &gt; /tmp/deklanche.d/pipe`.