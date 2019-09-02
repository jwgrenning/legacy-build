#! /bin/sh
# file: examples/equality_test.sh

testEquality()
{
  assertEquals 1 1
}

testFilterGccNoLinkErrors()
{
	assertEquals "Empty linker output" '' "$(echo '' | removeNonLinkErrors)"
	assertEquals "No undefined message" '' "$(echo 'some other error text' | removeNonLinkErrors)"
}

testFilterGccStandAloneCppFunction()
{
	line1="blah blah xxx.cpp:(blah): undefined reference to \`foo(bar)'"
	assertEquals '//cpp-function void foo(bar) { VOID_BOOM() }' "$(echo $line1 | makeCppFuncitonFakes)"
}

testFilterGccCppGlobal()
{
	line1="blah blah xxx.cpp:(blah): undefined reference to \`foo::foo'"
	assertEquals '//cpp-global foo::foo' "$(echo $line1 | listUndefinedCppGlobals)"
}

testFilterGccScopedCppFunction()
{
	line1="blah blah xxx.cpp:(blah): undefined reference to \`foo::foo(bar)'"
	assertEquals '//cpp-function void foo::foo(bar) { VOID_BOOM() }' "$(echo $line1 | makeCppFuncitonFakes)"
}

testFilterGccCFunction()
{
	line1="blah blah xxx.cpp:(blah): undefined reference to \`foo'"
	assertEquals '//c-function-or-global EXPLODING_FAKE_FOR(foo)' "$(echo $line1 | makeCFakes)"
}

testFilterGccCGlobalVariable()
{
	line1="blah blah xxx.cpp:(blah): undefined reference to \`global_var_foo'"
	assertEquals '//c-function-or-global EXPLODING_FAKE_FOR(global_var_foo)' "$(echo $line1 | makeCFakes)"
}

. $(dirname "$0")/gen-xfakes-func.sh
. ./shunit2/shunit2
