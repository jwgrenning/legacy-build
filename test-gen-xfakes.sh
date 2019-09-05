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


