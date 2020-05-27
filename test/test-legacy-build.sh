#!/bin/sh
. ../legacy-build.sh

TEST_DIR=.
TEMP_DIR=tmp
EXAMPLES_DIR=$TEST_DIR/example-output

test_get_filename_for_missing_include()
{
	error="blah fatal error: RandomMinuteGenerator.h: No such file or directory"
	assertEquals 'RandomMinuteGenerator.h' $(isolate_missing_file "${error}")
}

test_not_declared_suggestion()
{
	out=$(show_not_declared $EXAMPLES_DIR/gcc-undeclared-error.txt)
	assertEquals "show_not_declared should return 1 for not delcared errors" "0" "$?"
	assertContains "${out}" "#include"
}

find() #faking find
{
	echo "./foo/bar/Filename.h"
}

test_show_missing_include_path()
{
	out=$(show_missing_include_path $EXAMPLES_DIR/gcc-missing-include-path.txt)
	assertEquals "show_missing_include_path" "0" "$?"
	assertContains "${out}" "missing include path"
	assertContains "${out}" 'INCLUDE_DIRS += $(INCLUDE_ROOT)/foo/bar'
}

test_warning_suggestion()
{
	out="$(cat $EXAMPLES_DIR/gcc-warning.txt | show_warnings)"
	assertEquals "show_warnings" "0" "$?"
	assertContains "${out}" "turn off the warning"
	assertContains "${out}" "-Wno-"
}

helper_test_link_errors_exist()
{
	link_errors_exist $1
	assertEquals "link_errors_exist failed for $1" "0" "$?" 	
}

test_link_errors_exist_in_examples_gcc()
{
	helper_test_link_errors_exist $EXAMPLES_DIR/gcc-link-error-legacy.txt
	helper_test_link_errors_exist $EXAMPLES_DIR/gcc-link-errors.txt
}

test_link_errors_exist_in_examples_clang()
{
	helper_test_link_errors_exist $EXAMPLES_DIR/clang-link-errors.txt
}

test_link_errors_exist_in_examples_vs()
{
	helper_test_link_errors_exist $EXAMPLES_DIR/vs-link-errors.txt
}

test_other_error_not_confused_by_linker_error()
{
	out="$(show_other_compile_errors ${EXAMPLES_DIR}/gcc-link-error-legacy.txt)"
	assertEquals "show_other_compile_errors" "1" "$?"
}

test_other_error_give_up()
{
	out="$(show_other_compile_errors ${EXAMPLES_DIR}/gcc-other-error.txt)"
	assertEquals "show_other_compile_errors" "0" "$?"
	assertContains "${out}" "Sorry"
}

ignore_test_unique_link_errors()
{
	out="$(unique_link_errors ${EXAMPLES_DIR}/gcc-other-error.txt)"
	assertEquals "nothing" "${out}"
}

ignore_testUniqueLinkCount()
{
	out="$(unique_link_error_count $EXAMPLES_DIR/gcc-link-error-legacy.txt)"
	assertEquals "5" "${out}"
}

show_fakes_stats() # fake
{
	echo "Showing stats with grep"	
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
	assertContains "\n${out}\n" "Generated fakes file already exists"
}

testLinkErrorSuggestions()
{
	LS_OUTPUT="nothing"
	out="$(cat $EXAMPLES_DIR/gcc-link-error-legacy.txt | generate_fakes)"
	assertContains "\n${out}\n" "${out}" "Generating fakes"
	assertContains "\n${out}\n" "${out}" "run_generate_fakes_script"
}





. ../shunit2/shunit2


