#!/bin/bash

LEGACY_SUGGEST=$(dirname $0)/legacy-suggest.sh
GEN_XFAKES=$(dirname $0)/gen-xfakes.sh

if [[ ! -e "${LEGACY_SUGGEST}" ]]; then
    echo "error: missing ${LEGACY_SUGGEST}"
    exit 1
fi

if [[ ! -e "${GEN_XFAKES}" ]]; then
    echo "error: missing ${GEN_XFAKES}"
    exit 1
fi

source $LEGACY_SUGGEST
source $GEN_XFAKES

legacy_build_main()
{
    echo "legacy-build from $1, INCLUDE_ROOT=${INCLUDE_ROOT}, using build command $2"
    start_dir=${PWD}
    cd $1
    $2 2>$ERROR_FILE
    cat $ERROR_FILE
    legacy_build_suggestion $ERROR_FILE

    cd $start_dir
}

if [[ "$0" = "$BASH_SOURCE" ]]; then
    legacy_build_main $1 $2
fi
