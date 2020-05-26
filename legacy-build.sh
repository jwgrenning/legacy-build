#!/bin/bash

# gcc settings, -fatal-errors	
ERROR_FILE=build-errors.txt
FAKES_BASENAME=tmp-fakes
INCLUDE_ROOT=.
NOT_DECLARED_ERR="not declared in this scope"
INCLUDE_ERROR_STR="No such file or directory"
MAKEFILE_INCLUDE_STR="INCLUDE_DIRS += "
MAKEFILE_WARNING_STR="CPPUTEST_WARNINGFLAGS += "



translator()
{
	out=$(grep "$1")
	if [ ! -z "$out" ]; then
		echo $out
		echo "Looks like you need to $2"
		return 1
	fi
	return 0
}

show_noise_reduced_heading()
{
	echo "-----------------------------------------"
	echo "--------- Noise reduced output ----------"
	echo "-----------------------------------------"
}

show_not_declared()
{
	cat $1 | translator "${NOT_DECLARED_ERR}" "add a #include to your test file"
	return $?
}

missing_include_filename()
{
	sed -e's/.*fatal error: //' | sed -e's/:.*$//'
}

show_no_such_file_or_directory()
{
	cat $1 | translator "${INCLUDE_ERROR_STR}" "add an include path to your build"
	if [ "$?" != "0" ]; then
		filename=$(grep "${INCLUDE_ERROR_STR}" $1 | missing_include_filename)
		echo "Missing include path for '$filename'"
		cd $INCLUDE_ROOT
		echo "$ find . -name ${filename}"
		filepath=$(find . -name $filename)
		echo $filepath
		echo "Add '${MAKEFILE_INCLUDE_STR}$(dirname $filepath)' to your makefile"
		return 1
	fi
	return 0
}

show_unique_link_errors()
{
	grep "undefined reference to" | 
		sed -e's/^.* undefined/undefined/' -e's/ follow//' | sort | uniq
}

show_warnings()
{
	grep "\[\-W" $1
	test "$?" = "1" && return 0
	echo "You could [temporarily] turn off the warning with"
	echo "${MAKEFILE_INCLUDE_STR}-Wno-<warning-spec>"
	return 1
}

show_other_errors()
{
	grep ": error: " $1
	test "$?" = "1" && return 0
	echo "Sorry, I can't help with this error."
	return 1
}

unique_link_error_count()
{
	cat $1 | show_unique_link_errors | wc -l 
}

run_generate_fakes_script()
{
	bash gen-xfakes.sh $1 $2
}

generate_fakes()
{
	link_error_count=$(unique_link_error_count)
	echo "Link error count ${link_error_count}"
	if [ "${link_error_count}" = "0" ]; then
		return 1
	elif [ "${link_error_count}" = "1" ] || [ "${link_error_count}" = "2" ]; then
		echo "You have a single linker error to fix. -- Make a stub or add a file to the build"
	else
		if [ "$(ls ${FAKES_BASENAME}-*.* 2>/dev/null)" = "" ]; then
			echo "Generating fakes"
			run_generate_fakes_script $ERROR_FILE $FAKES_BASENAME
			echo "Review generated fakes, and incrementally add them to the build:"
			echo "$(ls ${FAKES_BASENAME}-*.*)"
		else
			echo "Generated fakes file already exists; delete or rename files for new gen-xfakes."
		fi
	fi
	return 0
}


legacy_build_suggestion()
{
	show_noise_reduced_heading
	show_not_declared $ERROR_FILE &&\
		show_no_such_file_or_directory $ERROR_FILE &&\
		show_warnings $ERROR_FILE &&\
		show_other_errors $ERROR_FILE &&\
		show_unique_link_errors $ERROR_FILE
	test "$unique_link_error_count)" != "0" && generate_fakes
}

legacy_build_main()
{
	start_dir=${PWD}
	cd $1
	make 2>$ERROR_FILE
	cat $ERROR_FILE
	cat $ERROR_FILE | legacy_build_action
	cd $start_dir
}

[ $0 = "legacy-build.sh" ] && legacy_build_main
