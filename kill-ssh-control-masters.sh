#!/bin/sh

# Assume SSH ControlMaster sockets are named according to home-manager's
# default ControlPath directive: `ControlPath ~/.ssh/master-%r@%n:%p`

for sockpath in ~/.ssh/master-*; do
    echo "$sockpath"
    ssh -O exit -S "$sockpath"
done
