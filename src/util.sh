#!/bin/sh

# Colours
BLACK='0;30'
RED='0;31'
GREEN='0;32'
ORANGE='0;33'
BLUE='0;34'
PURPLE='0;35'
CYAN='0;36'
LIGHT_GRAY='0;37'

DARK_GRAY='1;30'
LIGHT_RED='1;31'
LIGHT_GREEN='1;32'
YELLOW='1;33'
LIGHT_BLUE='1;34'
LIGHT_PURPLE='1;35'
LIGHT_CYAN='1;36'
WHITE='1;37'

ANSI_ESC='\033'
color() { echo -e "${ANSI_ESC}[${1}m"; }
RESET="$(color '0')"


# Logging
loginfo()  { log $CYAN INFO "$@"; }
logwarn()  { log $ORANGE WARN "$@"; }
logerror() { log $RED ERROR "$@"; telegram-api sendMessage "$(echo -e "<b>Downstreamer Error</b>\n$@")"; }
log() {
    local color="$1"
    local level="$2"
    shift 2 || true
    local message="$@"

    for f in "$LOGFILE" /dev/stderr; do
        [ -z "$f" ] && continue
        exec >>$f
        if [ -t 1 ]; then
            echo "$(date -Isec) <$(color $YELLOW)$(basename "$0")$RESET> $(color $color)[$level]$RESET $message"
        else
            echo "$(date -Isec) <$(basename "$0")> [$level] $message"
        fi
    done
}

upper() { echo $@ | tr a-z A-Z; }
lower() { echo $@ | tr A-Z a-z; }

esc() { echo "$@" | recode ascii..html; }

curlencode() { echo '-G'; printf '%s\0' "$@" | xargs -0 -n1 -I{} echo '--data-urlencode {}'; }

checkVars() {
    O=`getopt -- 'p:s:' "$@"` || exit 1
    eval set -- "$O"
    while true; do
        case "$1" in
        -p) prefix="$2"; shift 2;;
        -s) suffix="$2"; shift 2;;
        --) shift; break;;
        *)  logerror "$1";;
        esac
    done

    retval=0
    for var in $@; do
        varname="$prefix$var$suffix"
        if [ -z "$(printenv "$varname")" ]; then
            logerror "'$varname' value missing"
            retval=1
        fi
    done
    return $retval
}
