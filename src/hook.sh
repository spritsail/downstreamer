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

try_downstream() {
    while read ds; do
        ds_repo="$(echo $ds | cut -d' ' -f1)"
        should_trigger=true
        # Check each additional data argument for a match
        for var in $(echo $ds | cut -d' ' -f2-); do
            if ! echo $DATA | jq -e '. | index("'${var/\"/\\\"}'")' >/dev/null; then
                should_trigger=false
                loginfo "Downstream not triggered because '$var' not valid for $ds_repo"
                break
            fi
        done
        if [ "$should_trigger" == 'true' ]; then
            loginfo "Triggering downstream build for $ds_repo"
            downstream "$ds_repo"
        fi
    done < "$1"
}

# Check for downstream files
if [ -n "$TAG" -a -f "$CONFIG_DIR/$REPO:$BRANCH:$TAG"  ]; then
    try_downstream "$CONFIG_DIR/$REPO:$BRANCH:$TAG"
elif [ -f "$CONFIG_DIR/$REPO:$BRANCH" ]; then
    try_downstream "$CONFIG_DIR/$REPO:$BRANCH"
elif [ -f "$CONFIG_DIR/$REPO" ]; then
    try_downstream "$CONFIG_DIR/$REPO"
else
    loginfo "No downstream entries for $REPO"
fi
