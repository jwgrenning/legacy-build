#!/bin/bash

LEGACY_SUGGEST=$(dirname $0)/legacy-suggest.sh

if [[ ! -e "${LEGACY_SUGGEST}" ]]; then
    echo "error: missing ${LEGACY_SUGGEST}"
    exit 1
fi

source $LEGACY_SUGGEST

legacy_build_main()
{
    echo "legacy-build make from $1, INCLUDE_ROOT=${INCLUDE_ROOT}"
    start_dir=${PWD}
    cd $1
    make 2>$ERROR_FILE
    cat $ERROR_FILE
    legacy_build_suggestion $ERROR_FILE

    cd $start_dir
}

[ $0 = "legacy-build.sh" ] && legacy_build_main $1
