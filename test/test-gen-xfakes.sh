#! /bin/sh

TEST_DIR=.
TEMP_DIR=tmp
FAKES_BASENAME=xfakes
EXAMPLES_DIR=$TEST_DIR/example-output

testMakeCFake()
{
    c_undefined="someGlobal"
    assertEquals 'EXPLODING_FAKE_FOR(someGlobal)' "$(echo $c_undefined | makeCFakes)"
}

testMakeCFakeIgnoresCpp()
{
    cpp_function1="SomeClass::someFunction(Foo&)"
    cpp_function2="someFunction(Foo*)"
    cpp_global="SomeClass::someGlobal"
    assertEquals '' "$(echo $cpp_function1 | makeCFakes)"
    assertEquals '' "$(echo $cpp_function2 | makeCFakes)"
    assertEquals '' "$(echo $cpp_global | makeCFakes)"
}

testMakeCppFake()
{
    cpp_function1="SomeClass::someFunction(Foo&)"
    cpp_function2="someFunction(Foo*)"
    cpp_global="SomeClass::someGlobal"
    c_undefined="someGlobal"
    assertEquals '// void SomeClass::someFunction(Foo&) { BOOM_VOID_CPP }' "$(echo $cpp_function1 | makeCppFakes)"
    assertEquals '// void someFunction(Foo*) { BOOM_VOID_CPP }' "$(echo $cpp_function2 | makeCppFakes)"
    assertEquals '' "$(echo $cpp_global | makeCppFakes)"
    assertEquals '' "$(echo $c_undefined | makeCppFakes)"
}

testMakeCppGlobalFake()
{
    cpp_function1="SomeClass::someFunction(Foo&)"
    cpp_function2="someFunction(Foo*)"
    cpp_global="SomeClass::someGlobal"
    c_undefined="someGlobal"
    assertEquals '' "$(echo $cpp_function1 | makeCppGlobalFakes)"
    assertEquals '' "$(echo $cpp_function2 | makeCppGlobalFakes)"
    assertEquals '// cpp-global SomeClass::someGlobal;' "$(echo $cpp_global | makeCppGlobalFakes)"
    assertEquals '' "$(echo $c_undefined | makeCppGlobalFakes)"
}


testCommandLine()
{
    assertContains "$(generate_fakes)" "usage"
}

testSayWhenOverwriteingGeneratedFakes()
{
    LS_OUTPUT="something"
    out="$(generate_fakes $EXAMPLES_DIR/gcc-link-error-legacy.txt)"
    assertContains "\n${out}\n" "Removing earlier generated fakes"
}

testLinkErrorSuggestions()
{
    LS_OUTPUT="nothing"
    out="$(generate_fakes $EXAMPLES_DIR/gcc-link-error-legacy.txt)"
    assertContains "\n${out}\n" "${out}" "Generating fakes"
    assertContains "\n${out}\n" "${out}" "Removing earlier generated fakes"
}

diffWithGolden()
{
    assertEquals "$2 is different than golden copy" "" "$(diff ${TEST_DIR}/${TEMP_DIR}/$2 ${TEST_DIR}/golden/$2)"
}

checkOutputSameAsGolden()
{
    mkdir -p tmp
    generate_fakes $TEST_DIR/example-output/$1-link-errors.txt $TEST_DIR/$TEMP_DIR/$FAKES_BASENAME-$1
    diffWithGolden $1 $FAKES_BASENAME-$1-c.c
    diffWithGolden $1 $FAKES_BASENAME-$1-cpp.cpp
    diffWithGolden $1 $FAKES_BASENAME-$1-cpp-globals.cpp
}

    testOutputSameAsGoldenGcc()
    {
        checkOutputSameAsGolden gcc
    }

    # testOutputSameAsGoldenClang()
    # {
    #     checkOutputSameAsGolden clang
    # }

    # testOutputSameAsGoldenVS()
    # {
    #     checkOutputSameAsGolden vs
    # }

cleanup()
{
    rm -rf $TEST_DIR/$TEMP_DIR
}


cleanup
. ../gen-xfakes.sh 
. ../shunit2/shunit2
