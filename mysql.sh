#!/bin/bash
#
# Example of how to get mysql credentials into matiri; 
# You should probably use something more secure
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#


# First mysql server
declare -A SERVER_1
SERVER_1["MYSQL_USER"]="backups_user_1"
SERVER_1["MYSQL_HOST"]=host_1
SERVER_1["MYSQL_PASSWORD"]=password_1
SERVER_1["MYSQL_PORT"]=3306

# Second MySQL Server
declare -A SERVER_2
SERVER_2["MYSQL_USER"]=backups_user_2
SERVER_2["MYSQL_HOST"]=host_2
SERVER_2["MYSQL_PASSWORD"]=password_2
SERVER_2["MYSQL_PORT"]=3306


if [ "$#" != "2" ]; then
    echo "Error: expects two argument: server_id, ( user | host | password | port )" 1>&2
    exit 42
fi

SERVER_PTR="SERVER_$1"

MYSQL_USER="$SERVER_PTR[MYSQL_USER]"
MYSQL_HOST="$SERVER_PTR[MYSQL_HOST]"
MYSQL_PASSWORD="$SERVER_PTR[MYSQL_PASSWORD]"
MYSQL_PORT="$SERVER_PTR[MYSQL_PORT]"

# Ensure that the server definition exists by validating that it doesn't return empty
SERVER_EXISTS="$SERVER_PTR[@]"
if [[ ${!SERVER_EXISTS} == "" ]]; then
	echo "Error: Server $1 is not defined." 1>&2
	exit 42
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
