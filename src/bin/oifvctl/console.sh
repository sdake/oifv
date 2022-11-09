ch-remote --api-socket $HOME/oifv.sock info | jq -C .config.console
ch-remote --api-socket $HOME/oifv.sock info | jq -C .config.serial
screen /dev/pts/4
