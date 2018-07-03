#!/bin/sh
set -e

#############################
##      Configuration      ##
#############################

CONFIG_DIR="${CONFIG_DIR:-/config}"
LOG_DIR="${LOG_DIR:-/logs}"
LOGFILE="${LOGFILE:-"$LOG_DIR/$(basename "$0")-$(date -Idate)"}"
CURL_OPTS=${CURL_OPTS--fsSL}

#############################

export CONFIG_DIR LOG_DIR LOGFILE
export CURL_OPTS="$(echo ${CURL_OPTS} | sed 's/ /\n/g')"

source ./util.sh

checkVars -p HOOK_ repo branch build_number build_status
loginfo "Incoming notification for $HOOK_repo:$HOOK_branch (#$HOOK_build_number) [$HOOK_build_status]"

# Send a notification
notify-telegram || logwarn "Failed to send Telegram notification: $?"

# Check for downstream files
if [ -f "$CONFIG_DIR/$HOOK_repo:$HOOK_branch" ]; then
    while read ds; do
        loginfo "Triggering downstream build for $ds"
        downstream "$ds"
    done < "$CONFIG_DIR/$HOOK_repo:$HOOK_branch"

elif [ -f "$CONFIG_DIR/$HOOK_repo" ]; then
    while read ds; do
        loginfo "Triggering downstream build for $ds"
        downstream "$ds"
    done < "$CONFIG_DIR/$HOOK_repo"

else
    loginfo "No downstream entries for $HOOK_repo"
fi
