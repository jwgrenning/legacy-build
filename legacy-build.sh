#!/bin/bash

# gcc settings, -fatal-errors
ERROR_FILE=tmp-build-errors.txt
FAKES_BASENAME=tmp-fakes
INCLUDE_ROOT=${INCLUDE_ROOT:-.}
MAKEFILE_INCLUDE_STR=${MAKEFILE_INCLUDE_STR:-"INCLUDE_DIRS += "}
MAKEFILE_WARNING_STR=${MAKEFILE_WARNING_STR:-"CPPUTEST_WARNINGFLAGS += "}

declare -a not_declared=(
    "not\ declared\ in\ this\ scope"
    "unknown\ type\ name"
    )

declare -a include_head=(
    ".*\ error:\ '"
    ".*\ error:\ "
    )
declare -a include_tail=(
    ":\ No\ such\ file\ or\ directory"
    "'\ file\ not\ found"
    )

declare -a linker_error_in_file=(
    "error:\ ld"
    "clang:\ error:\ linker"
    "LNK2019"
    )

looks_like()
{
    echo "Looks like you $1"
}

show_not_declared()
{
    for text in "${not_declared[@]}"; do
        out=$(grep "${text}" $1)
        if [ "$?" = "0" ]; then
            echo $out
            looks_like "have a missing #include (${text})"
            return 0
        fi
    done
    return 1
}

show_missing_include_path()
{
    for text in "${include_tail[@]}"; do
        out=$(grep "${text}" $1)
        if [ "$?" = "0" ]; then
            echo $out
            looks_like "a missing include path in your makefile (${text})"
            grep "#include" $1
            file=$(isolate_missing_file "${out}")
            echo "Missing include path to ${file}"
            suggest_include_path $file
            return 0
        fi
    done
    return 1
}

isolate_missing_file()
{
    line="$@"
    for text in "${include_head[@]}" ]; do
        line=$(echo $line | sed -e"s/${text}//")
    done
    for text in "${include_tail[@]}" ]; do
        line=$(echo $line | sed -e"s/${text}//")
    done
    echo $line
}

suggest_include_path()
{
    cd $INCLUDE_ROOT
    target=$(basename $1)
    partial_path=$(dirname $1)
    search_path=${INCLUDE_ROOT}

    echo "$ cd ${INCLUDE_ROOT}"
    echo "$ find . -name ${target}"
    filepath=$(find . -name ${target})
    if [ "${filepath}" == "" ]; then
        echo "${target} not found under ${search_path}"
    else
        echo "Path to $1"
        echo $filepath
        if [ "${partial_path}" == "." ]; then
            dir=$(dirname $filepath)
            include_path="\$(INCLUDE_ROOT)${dir#?}"
            echo "Add this to your makefile:"
            echo "${MAKEFILE_INCLUDE_STR}${include_path}"
        fi
    fi
}

link_errors_exist()
{
    for text in "${linker_error_in_file[@]}"; do
        grep "${text}" $1 >/dev/null
        if [ "$?" == "0" ]; then
            return 0
        fi
    done
    return 1
}

show_noise_reduced_heading()
{
    echo "-----------------------------------------------------"
    echo "--------- Noise reduced build error output ----------"
    echo "-----------------------------------------------------"
}

show_warnings()
{
    grep "\[\-W" $1
    test "$?" = "1" && return 1
    echo "You could [temporarily] turn off the warning with"
    echo "${MAKEFILE_WARNING_STR}-Wno-<warning-spec>"
    return 0
}

show_other_compile_errors()
{
    link_errors_exist $1 && return 1
    grep ": error: " $1
    [ "$?" = "1" ] && return 1
    echo "Sorry, I can't help with this error."
    return 0
}

run_generate_fakes_script()
{
    bash gen-xfakes.sh $1 $2
}

show_fakes_stats()
{
    # generated fakes for C start with 'EXPLODING'
    # cpp test stub suggestions start with '// void'
    grep -c '^EXPLODING\|^// void' ${FAKES_BASENAME}-*.* | sed -e's/:/ generated /' -e's/$/ exploding fakes/'
}

generate_fakes()
{
    echo "You have linker errors."
    echo "Removing earlier generated fakes."
    rm -f ${FAKES_BASENAME}-*.*
    echo "Generating fakes."
    run_generate_fakes_script $ERROR_FILE $FAKES_BASENAME
    echo "Review generated fakes (${FAKES_BASENAME}-*.c*), to see your undefined external references."
    echo "You can incrementally add the exploding fakes to the build or "
    echo "resolve linker errors other ways."
    show_fakes_stats
    return 0
}

legacy_build_suggestion()
{
    show_noise_reduced_heading
    show_not_declared $1 && return 1
    show_missing_include_path $1 && return 1
    show_warnings $1 && return 1
    show_other_compile_errors $1 && return 1
    link_errors_exist $1 && generate_fakes
}

legacy_build_main()
{
    echo "legacy-build make from $1, INCLUDE_ROOT=$1"
    start_dir=${PWD}
    cd $1
    make 2>$ERROR_FILE
    cat $ERROR_FILE
    legacy_build_suggestion $ERROR_FILE

    cd $start_dir
}

[ $0 = "legacy-build.sh" ] && legacy_build_main $1
