#!/bin/bash
# script to backup a single mysql database
# $1=name of mysql db
# $2=destination filename for output
# # GNewton 2013.10.31
#
# Assumes in directory of (this) script
# Stop if any error occurs
set -e
LOG="0"
usage(){
    #echo "Usage: $0 configFile host dbName backupFileName errorlogFileName"
    echo "Usage: $0 host userid password dbName backupDirectory backupFileName errorLogFilename"
}

readonly DEPENDENCIES=(nice cat mysqldump gzip sha256sum date)

#Error Codes
readonly ERROR_USAGE_1=1
readonly ERROR_MYSQLDUMP_FAIL_2=2
readonly ERROR_GZIP_TEST_FAIL_3=3
readonly ERROR_SHA_CREATE_FAIL_4=4


function init {
    log "check dependencies"
    check_dependencies ${DEPENDENCIES[@]}
    if [ ! $? ]; then
	usage
    fi
    log "check dependencies done"
}


function main {
    if [ $# -ne 7 ]; then
	usage
	exit $ERROR_USAGE_1
    fi
    . ./util.sh
    init
 
    readonly DB_HOST="$1"
    readonly DB_PORT="$2"
    readonly DB_USER="$3"
    readonly DB_PASSWORD="$4"

    readonly DATABASE_NAME="$5"

    readonly BACKUP_FILE_NAME="$6"
    readonly ERROR_LOG_FILE_NAME="$7"

    readonly DEFAULT_CHARACTER_SET='utf8'

    TIME_STAMP=$(date "+%F %H:%M:%S%t%s")

    # Uncomment to get verbose 
    #LOG=0

    readonly COMPRESSED_BACKUP_FILENAME=${BACKUP_FILE_NAME}.gz

    echo "START: $TIME_STAMP" > ${BACKUP_FILE_NAME}.meta
    echo "BACKUP_FILE:  $COMPRESSED_BACKUP_FILENAME" >> ${BACKUP_FILE_NAME}.meta

    deleteIfExists ${BACKUP_FILE_NAME}
    deleteIfExists ${COMPRESSED_BACKUP_FILENAME}

    log "Starting backup of database: $DATABASE_NAME data to compressed file: $COMPRESSED_BACKUP_FILENAME"
    { /bin/nice -19 cat <(echo "SET FOREIGN_KEY_CHECKS=0;") <(/usr/bin/mysqldump \
	--add-locks \
	--comments=0 \
	--compact \
	--compress \
	--default-character-set=${DEFAULT_CHARACTER_SET} \
	--disable-keys \
	--extended-insert \
	--hex-blob \
	--host=${DB_HOST}\
    --max-allowed-packet=1G \
	--no-autocommit \
	--no-create-db \
	--password=${DB_PASSWORD} \
	--port=${DB_PORT} \
	--quick \
	--routines \
	--single-transaction \
	--skip-dump-date \
	--triggers \
	--user=${DB_USER} \
	$DATABASE_NAME) <(echo "SET FOREIGN_KEY_CHECKS=1;") | /bin/nice /bin/gzip  -c > $COMPRESSED_BACKUP_FILENAME; } 2>> ${ERROR_LOG_FILE_NAME}|| { echo "command failed"; exit 1; }

    # Verify gzip OK
    /bin/gzip --test $COMPRESSED_BACKUP_FILENAME

    # Make sha256 of file
    /usr/bin/sha256sum $COMPRESSED_BACKUP_FILENAME | sed 's, .*/, ,' > ${COMPRESSED_BACKUP_FILENAME}.sha256

    TIME_STAMP=$(date +%F%t%H:%M:%S%t%s)
    echo "END: $TIME_STAMP" >> ${BACKUP_FILE_NAME}.meta
    }


################
main $@
################







