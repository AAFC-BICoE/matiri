#!/bin/bash
# script to backup mysql databases one-by-one, then tar them together
#
# GNewton 2013.10.09
#
set -e

# Find location of this script; from http://stackoverflow.com/a/246128/459050
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
readonly SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# We move into the directory of where this script is to have all dependencies local
cd $SCRIPT_DIR
. util.sh
. sqlite3.sh

sqlite3 -separator " | " $1 "select id, host, end_time, bytes, file from backup where end_time >= \"2013-11\"  order by end_time;"



