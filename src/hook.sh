#!/bin/sh
set -e

#############################
##      Configuration      ##
#############################

export CONFIG_DIR=${CONFIG_DIR:-/config}
export CURL_OPTS="${CURL_OPTS:=-fsSLq -o /dev/null}"

#############################

source ./util.sh

checkVars -p HOOK_ repo branch build_number build_status
loginfo "Incoming notification for $HOOK_repo:$HOOK_branch (#$HOOK_build_number) [$HOOK_build_status]"

# Send a notification
notify-telegram

# Check for downstream files
if [ -f "$CONFIG_DIR/$HOOK_repo:$HOOK_branch" ]; then
    loginfo "Triggering downstream for $HOOK_repo:$HOOK_branch"
elif [ -f "$CONFIG_DIR/$HOOK_repo:$HOOK_branch" ]; then
    loginfo "Triggering downstream for $HOOK_repo"
else
    loginfo "No downstream entries for $HOOK_repo"
fi


# TODO: Ensure there are no builds running
    # Queue if there is
