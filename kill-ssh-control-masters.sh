#!/usr/bin/env bash

# Assume SSH ControlMaster sockets are named according to home-manager's
# default ControlPath directive: `ControlPath ~/.ssh/master-%r@%n:%p`

for sockpath in ~/.ssh/master-*; do
    echo "$sockpath"
    port=${sockpath#*:}
    dst=${sockpath#*/master-}
    dst=${dst%:$port}
    ssh -O exit "$dst" -p "$port"
done
