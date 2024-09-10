#!/bin/sh

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
    assertContains "${out}" "Missing include path to Filename.h"
    assertContains "${out}" 'INCLUDE_DIRS += $(INCLUDE_ROOT)/foo/bar'
}

test_show_missing_include_partial_path()
{
    out=$(show_missing_include_path $EXAMPLES_DIR/gcc-missing-include-partial-path.txt)
    assertEquals "show_missing_include_path" "0" "$?"
    assertContains "${out}" "Path to foo/bar/Filename.h"
    assertContains "${out}" './foo/bar/Filename.h'
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

testFilterLinkerErrorsClang()
{
    cpp_function1='  "SomeClass::someFunction(Foo&)", referenced from:'
    cpp_function2='  "someFunction(Foo*)", referenced from:'
    cpp_global='  "SomeClass::someGlobal", referenced from:'
    cpp_typeinfo="typeinfo for SomeClass'"
    c_undefined='  "_someGlobal", referenced from:'
    assertEquals 'SomeClass::someFunction(Foo&)' "$(echo $cpp_function1 | isolateUndefinedSymbolsClang)"
    assertEquals 'someFunction(Foo*)' "$(echo $cpp_function2 | isolateUndefinedSymbolsClang)"
    assertEquals 'SomeClass::someGlobal' "$(echo $cpp_global | isolateUndefinedSymbolsClang)"
    assertEquals '' "$(echo $cpp_typeinfo | isolateUndefinedSymbolsClang)"
    assertEquals 'someGlobal' "$(echo $c_undefined | isolateUndefinedSymbolsClang)"
}

testFilterLinkerErrorsGcc()
{
    cpp_function1="blah: undefined reference to \`SomeClass::someFunction(Foo&)'"
    cpp_function2="blah: undefined reference to \`someFunction(Foo*)'"
    cpp_global="blah: undefined reference to \`SomeClass::someGlobal'"
    c_undefined="blah: undefined reference to \`someGlobal'"
    assertEquals 'SomeClass::someFunction(Foo&)' "$(echo $cpp_function1 | isolateUndefinedSymbolsGcc)"
    assertEquals 'someFunction(Foo*)' "$(echo $cpp_function2 | isolateUndefinedSymbolsGcc)"
    assertEquals 'SomeClass::someGlobal' "$(echo $cpp_global | isolateUndefinedSymbolsGcc)"
    assertEquals 'someGlobal' "$(echo $c_undefined | isolateUndefinedSymbolsGcc)"
}

testFilterLinkerErrorsVS_Cpp()
{
    cpp_function1="blah: LNK2019 blah symbol \"SomeClass::someFunction(Foo&)\" blah blah"
    cpp_function2="blah: LNK2019 blah symbol \"__declspec(dllimport) someFunction(Foo*)\" blah blah"
    cpp_global="blah: LNK2019 blah symbol \"SomeClass::someGlobal\" blah blah"
    cpp_wierd_global="error LNK2001: unresolved external symbol \"public: static class beta alpha::var\" (?var@alpha@@2Vbeta@@A)"
    assertEquals 'SomeClass::someFunction(Foo&)' "$(echo $cpp_function1 | isolateUndefinedSymbolsVS_Cpp)"
    assertEquals '__declspec(dllimport) someFunction(Foo*)' "$(echo $cpp_function2 | isolateUndefinedSymbolsVS_Cpp)"
    assertEquals 'SomeClass::someGlobal' "$(echo $cpp_global | isolateUndefinedSymbolsVS_Cpp)"
    assertEquals 'public: static class beta alpha::var' "$(echo $cpp_wierd_global | isolateUndefinedSymbolsVS_Cpp)"
}

testFilterLinkerErrorsVS_Cpp_IgnoresC()
{
    c_undefined="blah: LNK2019 blah symbol _someGlobal referenced blah"
    assertEquals '' "$(echo $c_undefined | isolateUndefinedSymbolsVS_Cpp)"
}

testFilterLinkerErrorsVS_C()
{
    c_undefined="blah: LNK2019 blah symbol _someGlobal referenced blah"
    assertEquals 'someGlobal' "$(echo $c_undefined | isolateUndefinedSymbolsVS_C)"  
}

testFilterLinkerErrorsVS_C_IgnoresCpp()
{
    cpp_function1="blah: LNK2019 blah symbol \"SomeClass::someFunction(Foo&)\" blah blah"
    cpp_function2="blah: LNK2019 blah symbol \"__declspec(dllimport) someFunction(Foo*)\" blah blah"
    cpp_global="blah: LNK2019 blah symbol \"SomeClass::someGlobal\" blah blah"
    assertEquals '' "$(echo $cpp_function1 | isolateUndefinedSymbolsVS_C)"
    assertEquals '' "$(echo $cpp_function2 | isolateUndefinedSymbolsVS_C)"
    assertEquals '' "$(echo $cpp_global | isolateUndefinedSymbolsVS_C)"
}



. ../legacy-suggest.sh
. ../shunit2/shunit2
