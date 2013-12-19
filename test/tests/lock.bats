#!bats-install/bin/bats
source ../util.sh
LOCK_FILE="/tmp/foo_$$"

@test "acquire release lock" {
    if [[ -f "$lock_file" ]]; then
	rm "$lock_file"
    fi

    run acquire_lock "$LOCK_FILE"
    [ "$status" -eq 0 ]


    run release_lock "$LOCK_FILE"
    [ "$status" -eq 0 ]
}

@test "Acquire followed by acquire" {
    run acquire_lock "$LOCK_FILE"
    [ "$status" -eq 0 ]
    run acquire_lock "$LOCK_FILE"
    [ "$status" -ne 0 ]
}

@test "Acquire with no artuments" {
    run acquire_lock
    [ "$status" -ne 0 ]
}

@test "Release with no artuments" {
    run release_lock
    [ "$status" -ne 0 ]
}


