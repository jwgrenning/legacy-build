#!/bin/bash

LEGACY_SUGGEST=$(dirname $0)/legacy-suggest.sh
if [[ ! -e "${LEGACY_SUGGEST}" ]]; then
    echo "error: missing ${LEGACY_SUGGEST}"
    exit 1
fi

source $LEGACY_SUGGEST

GEN_XFAKES=$(dirname $0)/gen-xfakes.sh
if [[ ! -e "${GEN_XFAKES}" ]]; then
    echo "error: missing ${GEN_XFAKES}"
    exit 1
fi

source $GEN_XFAKES

BUILD_DIR=${1:-.}
INCLUDE_ROOT=${2:-.}
BUILD_COMMAND=${3:-make}

legacy_build_main()
{
    echo "legacy-build from BUILD_DIR=$BUILD_DIR, INCLUDE_ROOT=${INCLUDE_ROOT}, BUILD_COMMAND=$BUILD_COMMAND"
    start_dir=${PWD}
    cd $BUILD_DIR
    rm -r tmp-*.*
    $BUILD_COMMAND 2>$ERROR_FILE
    cat $ERROR_FILE
    legacy_build_suggestion $ERROR_FILE
    generate_fakes $SORTED_UNDEFINES

    cd $start_dir
}

if [[ "$0" = "$BASH_SOURCE" ]]; then
    legacy_build_main $1 $2 $3
fi
