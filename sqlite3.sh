# matiri: backup mysql databases in parallel, then tar them together; record the info in sqlite3 db (if available)
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#
readonly BACKUP_TABLE='backup_event'
readonly DB_TABLE='db_dump'

readonly NOT_COMPLETED="-999"
readonly COMPLETED="0"

HAVE_SQLITE=false

function sqlite_have_sqlite3 {
    if $HAVE_SQLITE == true || command_exists sqlite3; then
	HAVE_SQLITE=true
	return 0
    else
	return 1
    fi

}


# $1=database
function sqlite_init {
    if sqlite_have_sqlite3; then
	local readonly DB=$1
	log "Using sqlite3 database=${DB}"
	if sqlite_have_sqlite3; then
	    sqlite_table_exists $DB $BACKUP_TABLE
	    if [ $? -ne 0 ]; then
		sqlite_create_table $DB
	    fi
	    echo 0
	else
	    echo 1
	fi
    fi
}


# $1=dbfile; $2=table name
function sqlite_table_exists {
    if sqlite_have_sqlite3; then
	local readonly DB="$1"
	local readonly TABLE="$2"
	sel=$(sqlite3 $DB  "SELECT name FROM sqlite_master WHERE type='table' AND name='${TABLE}';" | wc -l)
	if [ $sel -eq 0 ]; then
	    return 1;
	fi
	return 0
    fi
    return 0
}

function sqlite_create_table {
    if sqlite_have_sqlite3; then
	local readonly DB="$1"
	log "Creating tables "
	$(sqlite3 $DB "CREATE TABLE $BACKUP_TABLE (id INTEGER PRIMARY KEY, completed int NOT NULL, comments text, host varchar(255) NOT NULL, port int NOT NULL, start_time DATETIME not null, end_time DATETIME not null, user varchar(64), bytes bigint NOT NULL, file text, sha256 char(64) NOT NULL, error default NULL);")
	$(sqlite3 $DB "CREATE INDEX ${BACKUP_TABLE}_start_time on ${BACKUP_TABLE}(start_time)")
	
	$(sqlite3 $DB "CREATE TABLE $DB_TABLE (id INTEGER PRIMARY KEY,  backup_id INTEGER, completed int NOT NULL, database varchar(255) NOT NULL, file text, start_time DATETIME not null, end_time DATETIME not null, bytes bigint NOT NULL, sha256 char(64) NOT NULL, error default NULL, FOREIGN KEY(backup_id) REFERENCES backup(id));")
	$(sqlite3 $DB "CREATE INDEX ${DB_TABLE}_start_time on ${DB_TABLE}(start_time);")
    fi
}


# $1=$dbfile $2=table_name $3=column
function sqlite_get_next_number {
    if sqlite_have_sqlite3; then
	local readonly DB="$1"
	local readonly TABLE="$2"
	local readonly COLUMN="$3"
	local num=$(sqlite3 $DB "select max(${COLUMN}) from ${TABLE};")
	if [[ $num -eq "" ]]; then
	    echo "1"
	    return
	else
	    echo $(($num+1))
	    return
	fi
    fi
    echo "1"
    
}


# $1=dbfile
function sqlite_get_next_backup_id {
    ID=$(date +%H-%M-%S_%N)
    if sqlite_have_sqlite3; then
	local readonly DB="$1"
	ID=$(sqlite_get_next_number $DB "${BACKUP_TABLE}" "id")
    fi
    echo $ID
}

# $1=dbfile
function sqlite_get_next_database_backup_id {
    ID="1"
    if sqlite_have_sqlite3; then
	local readonly DB="$1"
	ID=$(sqlite_get_next_number $DB "${DB_TABLE}" "id")
    fi
    echo $ID
}


# $1 dbfile; $2 array of sql commands
function sqlite_apply_sql {
    if sqlite_have_sqlite3; then
	log "Database: $1   SQL: $2"
	sqlite3 "$1" "$2"
    fi
}

    
function sqlite3_start_backup {
    if sqlite_have_sqlite3; then
	local DB="$1"
	local PID="$2"
	local USER="$3" 
	local HOST="$4"
	local PORT="$5"
	
	local START_DATE=$(sqlite_date)
	SQL="insert into ${BACKUP_TABLE} (id, completed, host, port, user, start_time, end_time, bytes, sha256) VALUES (${PID}, $NOT_COMPLETED, \"${HOST}\", ${PORT}, \"${USER}\", datetime('now','localtime'), "0", 0, \"\"); "
	sqlite_apply_sql "$DB" "$SQL"
    fi
}

function sqlite3_fail_backup {
    if sqlite_have_sqlite3; then
	local DB="$1"
	local PID="$2"
	local ERROR_STRING="$3"
	
	SQL="update ${BACKUP_TABLE} set end_time=datetime('now','localtime'), error=\"${ERROR_STRING}\" where id=${PID};"
	sqlite_apply_sql "$DB" "$SQL"
    fi
}

function sqlite3_end_backup {
    if sqlite_have_sqlite3; then
	local DB="$1"
	local PID="$2"
	local BACKUP_FILE=$3
	local SHA256="$4"
	local FILESIZE="$5"
	local END_DATE=$(sqlite_date)
	SQL="update ${BACKUP_TABLE} set completed=${COMPLETED}, end_time=datetime('now','localtime'), sha256=\"${SHA256}\", file=\"${BACKUP_FILE}\", bytes=${FILESIZE} where id=${PID};"
	sqlite_apply_sql "$DB" "$SQL"
    fi
}

function sqlite3_start_db_backup {
    if sqlite_have_sqlite3; then
	local START_TIME=$(sqlite_date)
	local DB="$1"
	local ID="$2"
	local BACKUP_ID="$3"
	local DATABASE="$4"
	local SQL="insert into ${DB_TABLE} (id, completed, backup_id, start_time, end_time, bytes, sha256, database) VALUES (${ID}, ${NOT_COMPLETED}, ${BACKUP_ID}, datetime('now','localtime'), ${NOT_COMPLETED}, 0, \"\", \"${DATABASE}\");"
	sqlite_apply_sql "$DB" "$SQL"
    fi
}

function sqlite3_end_db_backup {
    if sqlite_have_sqlite3; then
	local DB="$1"
	local ID="$2"
	local FILE="$3"
	local BYTES="$4"
	local SHA256="$5"
	#local SQL="update ${DB_TABLE} set completed=${COMPLETED}, end_time=CURRENT_TIMESTAMP, bytes=$BYTES, sha256=\"$SHA256\", file=\"${FILE}\" where id=\"${ID}\";"
	local SQL="update ${DB_TABLE} set completed=${COMPLETED}, end_time=datetime('now','localtime'), bytes=$BYTES, sha256=\"$SHA256\", file=\"${FILE}\" where id=\"${ID}\";"
	
	sqlite_apply_sql "$DB" "$SQL"
    fi
}

function sqlite_date {
    echo $(date "+%Y-%m-%d %H:%M:%S")
}
