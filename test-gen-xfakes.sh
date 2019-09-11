#! /bin/sh

testFilterClangLinkerErrors()
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

testFilterGccLinkerErrors()
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

testMakeCFake()
{
	cpp_function1="SomeClass::someFunction(Foo&)"
	cpp_function2="someFunction(Foo*)"
	cpp_global="SomeClass::someGlobal"
	c_undefined="someGlobal"
	assertEquals '' "$(echo $cpp_function1 | makeCFakes2)"
	assertEquals '' "$(echo $cpp_function2 | makeCFakes2)"
	assertEquals '' "$(echo $cpp_global | makeCFakes2)"
	assertEquals 'EXPLODING_FAKE_FOR(someGlobal)' "$(echo $c_undefined | makeCFakes2)"
}

testMakeCppFake()
{
	cpp_function1="SomeClass::someFunction(Foo&)"
	cpp_function2="someFunction(Foo*)"
	cpp_global="SomeClass::someGlobal"
	c_undefined="someGlobal"
	assertEquals '// void SomeClass::someFunction(Foo&) { BOOM_VOID_CPP }' "$(echo $cpp_function1 | makeCppFakes2)"
	assertEquals '// void someFunction(Foo*) { BOOM_VOID_CPP }' "$(echo $cpp_function2 | makeCppFakes2)"
	assertEquals '' "$(echo $cpp_global | makeCppFakes2)"
	assertEquals '' "$(echo $c_undefined | makeCppFakes2)"
}

testMakeCppGlobalFake()
{
	cpp_function1="SomeClass::someFunction(Foo&)"
	cpp_function2="someFunction(Foo*)"
	cpp_global="SomeClass::someGlobal"
	c_undefined="someGlobal"
	assertEquals '' "$(echo $cpp_function1 | makeCppGlobalFakes2)"
	assertEquals '' "$(echo $cpp_function2 | makeCppGlobalFakes2)"
	assertEquals '// cpp-global SomeClass::someGlobal;' "$(echo $cpp_global | makeCppGlobalFakes2)"
	assertEquals '' "$(echo $c_undefined | makeCppGlobalFakes2)"
}


testCommandLine()
{
	assertContains "$(gen_xfakes)" "usage"
	assertContains "$(gen_xfakes input_file.txt)" "usage"
	assertContains "$(gen_xfakes input_file.txt output_base_name)" ""
}

diffWithGolden()
{
	assertEquals "$2 is different than golden copy" "" "$(diff test/$2 test/golden/$1-$2)"
}

checkOutputSameAsGolden()
{
	gen_xfakes test/example-$1-link-errors.txt test/xfakes
	diffWithGolden $1 xfakes-c.c
	diffWithGolden $1 xfakes-cpp.cpp
	diffWithGolden $1 xfakes-cpp-globals.cpp
	rm test/xfakes*.*
}

testOutputSameAsGoldenGcc()
{
	checkOutputSameAsGolden gcc
}

testOutputSameAsGoldenClang()
{
	checkOutputSameAsGolden clang
}

. $(dirname "$0")/gen-xfakes.sh 
. ./shunit2/shunit2


