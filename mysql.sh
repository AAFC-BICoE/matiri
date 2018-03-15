#!/bin/bash
#
# Example of how to get mysql credentials into matiri; 
# You should probably use something more secure
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#


# Multiple server/port combinations are supported.
# Declare a SERVER_ID hash, where ID starts at 1 and increments: declare -A SERVER_1
# Specify the hash values for the following keys in the SERVER_ID hash: MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, MYSQL_PORT, INCLUDE, EXCLUDE
# NOTE: Defining MYSQL_HOST as "localhost" is known to cause issues with non-standard ports (other than 3306)
# NOTE: Either INCLUDE or EXCLUDE are supported but not both

# First mysql server
declare -A SERVER_1
SERVER_1["MYSQL_USER"]=root
SERVER_1["MYSQL_HOST"]=127.0.0.1
SERVER_1["MYSQL_PASSWORD"]=password
SERVER_1["MYSQL_PORT"]=3306
SERVER_1["INCLUDE"]="events" # List of databases to include
SERVER_1["EXCLUDE"]=""	# List of databases to exclude

# Second MySQL Server
declare -A SERVER_2
SERVER_2["MYSQL_USER"]=root
SERVER_2["MYSQL_HOST"]=127.0.0.1
SERVER_2["MYSQL_PASSWORD"]=password
SERVER_2["MYSQL_PORT"]=3307
SERVER_2["INCLUDE"]="events"
SERVER_2["EXCLUDE"]=""
SERVER_2["MYSQL_DUMP"]="ssh user@example.com mysqldump" # Example of ssh tunnelling

if [ "$#" != "2" ]; then
    echo "Error: expects two argument: server_id, ( user | host | password | port )" 1>&2
    exit 42
fi

SERVER_PTR="SERVER_$1"

MYSQL_USER="$SERVER_PTR[MYSQL_USER]"
MYSQL_HOST="$SERVER_PTR[MYSQL_HOST]"
MYSQL_PASSWORD="$SERVER_PTR[MYSQL_PASSWORD]"
MYSQL_PORT="$SERVER_PTR[MYSQL_PORT]"
MYSQL_INCLUDE="$SERVER_PTR[INCLUDE]"
MYSQL_EXCLUDE="$SERVER_PTR[EXCLUDE]"
MYSQL_DUMP="$SERVER_PTR[MYSQL_DUMP]"

# Ensure that the server definition exists by validating that it doesn't return empty
SERVER_EXISTS="$SERVER_PTR[@]"
if [[ ${!SERVER_EXISTS} == "" ]]; then
	if [ $2 == "test" ]; then
		exit 1
	else
		echo "Error: Server $1 is not defined." 1>&2
		exit 50
	fi
fi

if [ "$2" == "user" ]; then
    echo ${!MYSQL_USER}
    exit;
fi

if [ "$2" == "host" ]; then
    echo ${!MYSQL_HOST}
    exit;
fi

if [ "$2" == "password" ]; then
    echo ${!MYSQL_PASSWORD}
    exit;
fi

if [ "$2" == "port" ]; then
    echo ${!MYSQL_PORT}
    exit;
fi


if [ "$2" == "include" ]; then
    echo ${!MYSQL_INCLUDE}
    exit;
fi

if [ "$2" == "exclude" ]; then
    echo ${!MYSQL_EXCLUDE}
    exit;
fi
