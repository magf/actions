#!/bin/bash
# collect-logs/tests/create_logs.bash
# shellcheck disable=SC2154 # using -u option
set -eux

# shellcheck source=/dev/null
source list~

function _main () {
mkdir -p "${dirs[@]}"
touch "${files[@]}"
# Debug
ls -la "${dirs[@]}"
ls -la "${files[@]}"
}

_main "$@"
