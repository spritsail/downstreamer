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
logerror() { log $RED ERROR "$@"; }
log() {
    local color="$1"
    local level="$2"
    shift 2
    local message="$@"

    if [ -t 1 ]; then
        echo "$(date -Isec) <$(color $YELLOW)$(basename "$0")$RESET> $(color $color)[$level]$RESET $message"
    else
        echo "$(date -Isec) <$(basename "$0") [$level] $message"
    fi
}


error() { logerror "$@"; >&2 echo -e "Error: $(basename "$0"): $@"; exit 1; }

upper() { echo $@ | tr a-z A-Z; }
lower() { echo $@ | tr A-Z a-z; }

checkVars() {
    O=`getopt -- 'p:s:' "$@"` || exit 1
    eval set -- "$O"
    while true; do
        case "$1" in
        -p) prefix="$2"; shift 2;;
        -s) suffix="$2"; shift 2;;
        --) shift; break;;
        *)  error "$1";;
        esac
    done

    for var in $@; do
        varname="$prefix$var$suffix"
        [ -z "$(printenv "$varname")" ] &&
            error "'$varname' value missing"
    done
    return 0
}

# ensureArgs $# <n> <name1> <..name2>
ensureArgs() {
    actual=$1
    required=$2
    shift 2

    if [ $actual -lt $required ]; then
        error "Missing required arguments: $@"
    fi
}
