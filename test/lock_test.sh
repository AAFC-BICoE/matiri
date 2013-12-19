#!/bin/bash
set -e

declare -a these_tests
unit_tests=(test_acquire_release_lock test_double_acquire_lock test_release_no_argument_lock test_acquire_no_argument_lock)

source ../util.sh

LOCK_FILE="/tmp/foo_$$"

function test_acquire_release_lock {
    if [[ -f "$lock_file" ]]; then
	rm "$lock_file"
    fi
    set +e
    acquire_lock "$LOCK_FILE"

    return_code=$?

    if [ $return_code != 0 ]; then
	return $return_code
    fi

    set +e
    release_lock "$LOCK_FILE"
    return_code=$?
    set -e
    if [ $return_code != 0 ]; then
	return $return_code
    fi
    set -e
    return 0 
}

function test_double_acquire_lock {
    acquire_lock "$LOCK_FILE"
    test_acquire_release_lock
    if [ $? != 0 ]; then
	return 0
    fi
    return 42
}

function test_acquire_no_argument_lock {
    acquire_lock
    if [ $? != 0 ]; then
	return 0
    fi
    return 42
}

function test_release_no_argument_lock {
    release_lock
    if [ $? != 0 ]; then
	return 0
    fi
    return 42
}

