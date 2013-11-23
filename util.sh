#
# utiliy library for matiri
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#
# Except for code from http://google-styleguide.googlecode.com/svn/trunk/shell.xml?showone=STDOUT_vs_STDERR#STDOUT_vs_STDERR v1.26
#  - function err()

function commandExists {
    command -v $1 >/dev/null 2>&1
}

function thisFunc {
    echo ${FUNCNAME[ 1 ]}
}

function parent {
    echo ${FUNCNAME[ 2 ]}
}

# $1=expected; $2=actual
function expects {
    local readonly EXPECTED=$1
    local readonly ACTUAL=$2
    if [ $EXPECTED -eq $ACTUAL ]; then
	return 0
    fi
    
    echo "Error: function $(parent) expects: $1 arguments; passed $2 arguments"
    exit 1
}

function test {
    "$@"
    status=$?
    if [ $status -ne 0 ]
    then
        echo "error with $1"
    fi
    return $status
}

function deleteIfExists {
    filename="$1"
    if [ -e $filename ]
    then
	rm -f $filename
    fi
}

readonly LOG_INFO="INFO: "
readonly LOG_ERROR="ERROR: "

function log {
    if [ $LOG == true ]; then
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]  ($(parent))    $@" >&2
    fi
}

# From http://google-styleguide.googlecode.com/svn/trunk/shell.xml?showone=STDOUT_vs_STDERR#STDOUT_vs_STDERR v1.26
function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# $1=#columns
function get_sha {
    expects 2 $#
    if [ ! -e $2 ]; then
	echo "File does not exist: $2" >&2 
    fi
    echo $(colrm $1 < $2)
}

# $1=this database; $2=WANTED_DATABASES_ARRAY
function shouldBackup {
    if [ $# -eq 1 ]; then
	echo "0"
	return
    fi
    DATABASE=$1
    shift

    WANTED_DBS=("${@}")
    for WANTED_DB in "${WANTED_DBS[@]}"   # or simply "for i; do"
    do
	if [ "$WANTED_DB" == "$DATABASE" ]; then
	    echo "0"
	    return
	fi
    done

    echo "1"
}

# $1=this database; $2=WANTED_DATABASES_ARRAY
function shouldBackup2 {
    if [ $# -eq 1 ]; then
	echo "0"
	return
    fi
    DATABASE=$1
    shift

    WANTED_DBS=("${@}")
    for WANTED_DB in "${WANTED_DBS[@]}"   # or simply "for i; do"
    do
	if [ "$WANTED_DB" == "$DATABASE" ]; then
	    echo "0"
	    return
	fi
    done
    echo "1"
    return
}
