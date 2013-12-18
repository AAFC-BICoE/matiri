#!/bin/bash
#
# Example of how to get mysql credentials into matiri; 
# You should probably use something more secure
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#

MYSQL_USER=backups
MYSQL_HOST=localhost
MYSQL_PASSWORD=mypass
MYSQL_PORT="3306"

if [ "$#" != "1" ]; then
    echo "Error: expects one argument: user || host || password || port" 1>&2
    exit 42
fi

if [ "$1" == "user" ]; then
    echo $MYSQL_USER
    exit;
fi

if [ "$1" == "host" ]; then
    echo $MYSQL_HOST
    exit;
fi

if [ "$1" == "password" ]; then
    echo $MYSQL_PASSWORD
    exit;
fi


if [ "$1" == "port" ]; then
    echo $MYSQL_PORT
    exit;
fi
