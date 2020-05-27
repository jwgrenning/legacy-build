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
			file=$(isolate_missing_file "${out}")
			echo "Missing path to ${file}"
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
	echo "$ find . -name $1 # from ${INCLUDE_ROOT}"
	filepath=$(find . -name $1)
	if [ "${filepath}" == "" ]; then
		echo "File not found under ${INCLUDE_ROOT}"
	else
		dir=$(dirname $filepath)
		include_path="\$(INCLUDE_ROOT)${dir#?}"
		echo $filepath
		echo "Add this to your makefile:"	
		echo "${MAKEFILE_INCLUDE_STR}${include_path}"
	fi	
}

link_errors_exist()
{
	echo "link_errors_exist check for $1"
	for text in "${linker_error_in_file[@]}"; do
		echo grep "${text}" $1
		grep "${text}" $1
		if [ "$?" == "0" ]; then
			return 0
		fi
	done
	return 1
}

show_noise_reduced_heading()
{
	echo "-----------------------------------------"
	echo "--------- Noise reduced output ----------"
	echo "-----------------------------------------"
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
	grep -c "BOOM" ${FAKES_BASENAME}-*.* | sed -e's/:/ generated /' -e's/$/ exploding fakes/'
}

generate_fakes()
{
	echo "You have linker errors. -- Add a file, make stubs or use the gernerated exploding fakes"
	if [ "$(ls ${FAKES_BASENAME}-*.* 2>/dev/null)" = "" ]; then
		echo "Generating fakes"
		run_generate_fakes_script $ERROR_FILE $FAKES_BASENAME
		echo "Review generated fakes, and incrementally add them to the build:"
		show_fakes_stats
	else
		echo "Generated fakes file already exists; delete or rename files for new gen-xfakes."
	fi
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
