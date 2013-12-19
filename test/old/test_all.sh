#!/bin/bash
#
#
# Author: GNewton 2013.10.09 glen.newton@gmail.com
# Copyright 2013 Government of Canada and Glen Newton
# Apache v2 License
#

declare -a tests
tests=(lock_test.sh)
LOG=true

pass_counter=0
declare -a pass_list
pass_list=()
fail_counter=0
declare -a fail_list
fail_list=()

for test in ${tests[@]}; do
    . $test

    for this_test in ${unit_tests[@]}; do
	$this_test
	return_code=$?
	
	if [ $return_code != 0 ]; then
	    log " FAIL: source: $test; test=$this_test; error=${return_code}"
	    fail_counter=$((fail_counter + 1))
	    fail_list[${#fail_list[@]}]="$test::$this_test"
	else
	    log " PASS: source: $test; test=$this_test"
	    pass_counter=$((pass_counter + 1))
	    pass_list[${#pass_list[@]}]="$test::$this_test  "
	fi
    done
    total_tests=`expr $pass_counter + $fail_counter`
    if [[ $fail_counter -gt 0 ]]; then
	log "FAILED TESTS $fail_counter / $total_tests"
	log "FAILED TESTS: ${fail_list[@]}"
    fi

    if [[ $pass_counter -gt 0 ]]; then
	log "PASSED TESTS $pass_counter/$total_tests"
	log "PASSED TESTS: ${pass_list[@]}"
    fi
done

