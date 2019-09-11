#! /bin/sh

testFilterGccNoLinkErrors()
{
	assertEquals "Empty linker output" '' "$(echo '' | removeNonLinkErrors)"
	assertEquals "No undefined message" '' "$(echo 'some other error text' | removeNonLinkErrors)"
}

testFilterGccStandAloneCppFunction()
{
	line="xxx:(xxx): undefined reference to \`AcmeWpa::restartDhcp(foo, bar*)'"
	assertEquals '// void AcmeWpa::restartDhcp(foo, bar*) { BOOM_VOID_CPP }' "$(echo $line | makeCppFakes)"
	assertEquals '' "$(echo $line | makeCFakes)"
	assertEquals '' "$(echo $line | makeCppGlobalFakes)"
}

testFilterClangLinkerErrors()
{
	cpp_function1='  "SomeClass::someFunction(Foo&)", referenced from:'
	cpp_function2='  "someFunction(Foo*)", referenced from:'
	cpp_global='  "SomeClass::someGlobal", referenced from:'
	c_undefined='  "_someGlobal", referenced from:'
	assertEquals 'SomeClass::someFunction(Foo&)' "$(echo $cpp_function1 | isolateUndefinedSymbolsClang)"
	assertEquals 'someFunction(Foo*)' "$(echo $cpp_function2 | isolateUndefinedSymbolsClang)"
	assertEquals 'SomeClass::someGlobal' "$(echo $cpp_global | isolateUndefinedSymbolsClang)"
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


testFilterGccCppGlobal()
{
	line="xxx:(xxx): undefined reference to \`foo::foo'"
	assertEquals '//cpp-global foo::foo;' "$(echo $line | makeCppGlobalFakes)"
	assertEquals '' "$(echo $line | makeCFakes)"
	assertEquals '' "$(echo $line | makeCppFakes)"
}

testFilterGccScopedCppFunction()
{
	line="blah:(blah): undefined reference to \`foo::foo(bar)'"
	assertEquals '// void foo::foo(bar) { BOOM_VOID_CPP }' "$(echo $line | makeCppFakes)"
	assertEquals '' "$(echo $line | makeCFakes)"
	assertEquals '' "$(echo $line | makeCppGlobalFakes)"
}

testFilterGccCFunction()
{
	line="blah:(blah): undefined reference to \`foo'"
	assertEquals 'EXPLODING_FAKE_FOR(foo)' "$(echo $line | makeCFakes)"
	assertEquals '' "$(echo $line | makeCppFakes)"
	assertEquals '' "$(echo $line | makeCppGlobalFakes)"
}

testFilterGccCGlobalVariable()
{
	line="blah:(blah): undefined reference to \`global_var_foo'"
	assertEquals 'EXPLODING_FAKE_FOR(global_var_foo)' "$(echo $line | makeCFakes)"
}

testCommandLine()
{
	assertContains "$(gen_xfakes)" "usage"
	# assertContains "$(gen_xfakes input_file.txt)" "usage"
	# assertContains "$(gen_xfakes input_file.txt output_base_name)" ""
}

diffWithGolden()
{
	assertEquals "$1 is different than golden copy" "" "$(diff test/$1 test/golden/$1)"
}

testOutputSameAsGolden()
{
	gen_xfakes test/example-gcc-link-errors.txt test/myfakes
	diffWithGolden myfakes-c.c
	diffWithGolden myfakes-cpp.cpp
	diffWithGolden myfakes-cpp-globals.cpp
}

cleanupOutput()
{
	rm -f test/myfakes-c.c
	rm -f test/myfakes-cpp*.cpp
}

oneTimeSetUp()
{
	cleanupOutput
}

oneTimeTearDown()
{
	cleanupOutput
}


. $(dirname "$0")/gen-xfakes.sh 
. ./shunit2/shunit2


