#!/bin/sh
set -e

#############################
##      Configuration      ##
#############################

CONFIG_DIR=${CONFIG_DIR:-/config}

#############################

source ./util.sh

checkVars -p HOOK_ repo branch status
loginfo "Incoming notification for $HOOK_build:$HOOK_branch [$HOOK_status]"

# Send a notification
notify-telegram

# Check for downstream files
checkVars HOOK_repo
if [ -f "$CONFIG_DIR/$HOOK_repo:$HOOK_branch" ]; then
    loginfo "Triggering downstream for $HOOK_repo:$HOOK_branch"
elif [ -f "$CONFIG_DIR/$HOOK_repo:$HOOK_branch" ]; then
    loginfo "Triggering downstream for $HOOK_repo"
else
    loginfo "No downstream entries for $HOOK_repo"
fi


# TODO: Ensure there are no builds running
    # Queue if there is
