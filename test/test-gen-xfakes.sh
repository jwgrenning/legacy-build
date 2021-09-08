#! /bin/sh

TEST_DIR=.
TEMP_DIR=tmp
FAKES_BASENAME=xfakes

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
    assertContains "$(gen_xfakes)" "usage"
    assertContains "$(gen_xfakes input_file.txt)" "usage"
    assertContains "$(gen_xfakes input_file.txt output_base_name)" ""
}


diffWithGolden()
{
    assertEquals "$2 is different than golden copy" "" "$(diff ${TEST_DIR}/${TEMP_DIR}/$2 ${TEST_DIR}/golden/$2)"
}


cleanup()
{
    rm -r $TEST_DIR/$TEMP_DIR   
}

checkOutputSameAsGolden()
{
    mkdir -p tmp
    gen_xfakes $TEST_DIR/example-output/$1-link-errors.txt $TEST_DIR/$TEMP_DIR/$FAKES_BASENAME-$1
    diffWithGolden $1 $FAKES_BASENAME-$1-c.c
    diffWithGolden $1 $FAKES_BASENAME-$1-cpp.cpp
    diffWithGolden $1 $FAKES_BASENAME-$1-cpp-globals.cpp
}

testOutputSameAsGoldenGcc()
{
    checkOutputSameAsGolden gcc
}

testOutputSameAsGoldenClang()
{
    checkOutputSameAsGolden clang
}

testOutputSameAsGoldenVS()
{
    checkOutputSameAsGolden vs
}

cleanup 
. ../gen-xfakes.sh 
. ../shunit2/shunit2


