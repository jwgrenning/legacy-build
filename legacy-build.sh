#!/bin/bash

# gcc settings, -fatal-errors	
ERROR_FILE=build-errors.txt
FAKES_BASENAME=tmp-fakes
INCLUDE_ROOT=.
NOT_DECLARED_ERR="not declared in this scope"
INCLUDE_ERROR_STR="No such file or directory"
MAKEFILE_INCLUDE_STR="INCLUDE_DIRS += "
MAKEFILE_WARNING_STR="CPPUTEST_WARNINGFLAGS += "
## declare an array variable
declare -a not_declared=(
	"not declared in this scope"
	"unknown type name"
	)

declare -a include_head=(
	".* error: "
	".* error: '"
	)
declare -a include_tail=(
	": No such file or directory"
	"' file not found"
	)

declare -a linker_error_in_file=(
	": error: ld"
	"clang: error: linker"
	"LNK2019"
	)

looks_like()
{
	echo "Looks like you $1"
}

show_not_declared()
{
	for text in "${not_declared[@]}" ]; do
		out=$(grep -e "${text}" $1)
		if [ "$?" = "0" ]; then
			echo $out
			looks_like "have a missing #include (${text})"
			return 1
		fi
	done
	return 0
}

show_missing_include_path()
{
	for text in "${include_tail[@]}" ]; do
		out=$(grep -e "${text}" $1)
		if [ "$?" = "0" ]; then
			echo $out
			looks_like "a missing include path in your makefile (${text})"
			file=$(isolate_missing_file "${out}")
			echo "Missing path to ${file}"
			suggest_include_path $file
			return 1
		fi
	done
	return 0
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
	echo "$ find . -name ${filename}"
	filepath=$(find . -name $filename)
	if [ "${filepath}" == "" ]; then
		echo "File not found under ${INCLUDE_ROOT}"
	else
		echo $filepath
		echo "Add this to your makefile:"	
		echo "${MAKEFILE_INCLUDE_STR}$(dirname $filepath)"
	fi	
}

link_errors_exist()
{
	for text in "${linker_error_in_file[@]}" ]; do
		grep "${text}" $1 >/dev/null
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
	test "$?" = "1" && return 0
	echo "You could [temporarily] turn off the warning with"
	echo "${MAKEFILE_INCLUDE_STR}-Wno-<warning-spec>"
	return 1
}

show_other_compile_errors()
{
	grep ": error: ld" $1 >/dev/null
	test "$?" = "0" && return 1
	grep ": error: " $1
	test "$?" = "1" && return 1
	echo "Sorry, I can't help with this error."
	return 0
}

run_generate_fakes_script()
{
	bash gen-xfakes.sh $1 $2
}

generate_fakes()
{
	[ ! link_errors_exist ] && return 1 
	echo "You have linker errors. -- Add a file, make stubs or use the gernerated exploding fakes"
	if [ "$(ls ${FAKES_BASENAME}-*.* 2>/dev/null)" = "" ]; then
		echo "Generating fakes"
		run_generate_fakes_script $ERROR_FILE $FAKES_BASENAME
		echo "Review generated fakes, and incrementally add them to the build:"
		echo "$(ls ${FAKES_BASENAME}-*.*)"
	else
		echo "Generated fakes file already exists; delete or rename files for new gen-xfakes."
	fi
	return 0
}

legacy_build_suggestion()
{
	show_noise_reduced_heading
	show_not_declared $ERROR_FILE &&\
		show_missing_include_path $ERROR_FILE &&\
		show_warnings $ERROR_FILE &&\
		show_other_compile_errors $ERROR_FILE
	test link_errors_exist && generate_fakes
}

legacy_build_main()
{
	start_dir=${PWD}
	cd $1
	make 2>$ERROR_FILE
	cat $ERROR_FILE
	cat $ERROR_FILE | legacy_build_suggestion
	cd $start_dir
}

[ $0 = "legacy-build.sh" ] && legacy_build_main $1
