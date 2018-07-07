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

checkVars REPO BRANCH BUILD_NUMBER BUILD_STATUS
loginfo "Incoming notification for $REPO:$BRANCH (#$BUILD_NUMBER) [$BUILD_STATUS]"

# Send a notification
notify-telegram || logwarn "Failed to send Telegram notification: $?"

# Check for downstream files
if [ -f "$CONFIG_DIR/$REPO:$BRANCH" ]; then
    while read ds; do
        loginfo "Triggering downstream build for $ds"
        downstream "$ds"
    done < "$CONFIG_DIR/$REPO:$BRANCH"

elif [ -f "$CONFIG_DIR/$REPO" ]; then
    while read ds; do
        loginfo "Triggering downstream build for $ds"
        downstream "$ds"
    done < "$CONFIG_DIR/$REPO"

else
    loginfo "No downstream entries for $REPO"
fi
