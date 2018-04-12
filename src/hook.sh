#!/bin/sh
set -e

source ./util.sh

# Send a notification
notify-telegram

# TODO: Check for downstream files

# TODO: Ensure there are no builds running
    # Queue if there is
