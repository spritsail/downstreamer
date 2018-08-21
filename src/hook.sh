#!/bin/sh
set -e

#############################
##      Configuration      ##
#############################

CONFIG_DIR="${CONFIG_DIR:-/config}"
LOG_DIR="${LOG_DIR:-/logs}"
LOGFILE="${LOGFILE:-"$LOG_DIR/$(basename "$0")-$(date -Idate)"}"
CURL_OPTS=${CURL_OPTS--fsSL --retry-connrefused --retry 5 --retry-delay 5 --connect-timeout 5 --max-time 10}

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

        # Check each at least the required arguments are provided using 'comm' to find common lines
        required_data="$(mktemp)"
        provided_data="$(mktemp)"
        echo "$ds" | sed -e 's/^[^\ ]*\ *//' | tr ' ' '\n' > "$required_data"
        echo "$DATA" | jq -r '.[]' > "$provided_data"
        if [ "$(comm -23 "$required_data" "$provided_data" | wc -l)" -eq 0 ]; then
            should_trigger=false
            loginfo "Downstream not triggered because '$var' not valid for $ds_repo"
        fi
        rm -f "$required_data" "$provided_data"

        if [ "$should_trigger" == 'true' ]; then
            loginfo "Triggering downstream build for $ds_repo"
            downstream "$ds_repo"
        fi
    done < "$1"
}

# Check for downstream files
if [ "$BUILD_STATUS" != 'success' ]; then
    loginfo "Build failed. Not triggering any downstream builds"
elif [ -n "$TAG" -a -f "$CONFIG_DIR/$REPO:$BRANCH:$TAG" ]; then
    try_downstream "$CONFIG_DIR/$REPO:$BRANCH:$TAG"
elif [ -f "$CONFIG_DIR/$REPO:$BRANCH" ]; then
    try_downstream "$CONFIG_DIR/$REPO:$BRANCH"
elif [ -f "$CONFIG_DIR/$REPO" ]; then
    try_downstream "$CONFIG_DIR/$REPO"
else
    loginfo "No downstream entries for $REPO"
fi
