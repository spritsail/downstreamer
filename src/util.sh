#!/bin/sh

error() { >&2 echo -e "Error: $(basename "$0"): $@"; exit 1; }

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
