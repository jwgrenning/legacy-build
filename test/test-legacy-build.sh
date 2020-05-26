#!/bin/sh
. ../legacy-build.sh 

TEST_DIR=.
TEMP_DIR=tmp
EXAMPLES_DIR=$TEST_DIR/example-output

testGetFilenameForMissingInclude()
{
	error="blah fatal error: RandomMinuteGenerator.h: No such file or directory"
	assertEquals 'RandomMinuteGenerator.h' $(echo "${error}" | missing_include_filename)
}

testNotDeclaredSuggestion()
{
	out="$(cat $EXAMPLES_DIR/gcc-undeclared-error.txt | show_not_declared)"
	assertEquals "show_not_declared should return 1 for not delcared errors" "1" "$?" 
	assertContains "${out}" "add a #include"
}

find() #faking find
{
	echo "./foo/bar/Filename.h"
}

testNoSuchFileOrDirecorySuggestion()
{
	out="$(cat $EXAMPLES_DIR/gcc-missing-include-path.txt | show_no_such_file_or_directory)"
	assertEquals "show_no_such_file_or_directory" "1" "$?" 
	assertContains "${out}" "Missing include path"
	assertContains "${out}" "INCLUDE_DIRS += ./foo/bar"
}

testWarningSuggestion()
{
	out="$(cat $EXAMPLES_DIR/gcc-warning.txt | show_warnings)"
	assertEquals "show_warnings" "1" "$?" 
	assertContains "${out}" "turn off the warning"
	assertContains "${out}" "-Wno-"
}

testOtherErrorGiveUp()
{
	out="$(cat $EXAMPLES_DIR/gcc-other-error.txt | show_other_errors)"
	assertEquals "show_other_errors" "1" "$?" 
	assertContains "${out}" "Sorry"
}

testUniqueLinkCount()
{
	out="$(cat $EXAMPLES_DIR/gcc-link-error-legacy.txt | unique_link_error_count)"
	assertEquals "5" "${out}"
}

LS_OUTPUT=""
ls()
{
	if [ "${LS_OUTPUT}" = "nothing" ]; then
		:
	else
		echo "fake run ls $1"
	fi
}


run_generate_fakes_script()
{
	echo "fake run_generate_fakes_script $1 $2"
}

testWontOverwriteGeneratedFakes()
{
	LS_OUTPUT="something"
	out="$(cat $EXAMPLES_DIR/gcc-link-error-legacy.txt | generate_fakes)"
	assertContains "\n${out}\n" "Link error count 5"
	assertContains "\n${out}\n" "Generated fakes file already exists"
}

testLinkErrorSuggestions()
{
	LS_OUTPUT="nothing"
	out="$(cat $EXAMPLES_DIR/gcc-link-error-legacy.txt | generate_fakes)"
	assertContains "\n${out}\n" "${out}" "Link error count 5"
	assertContains "\n${out}\n" "${out}" "Generating fakes"
	assertContains "\n${out}\n" "${out}" "run_generate_fakes_script"
}

. ../shunit2/shunit2


