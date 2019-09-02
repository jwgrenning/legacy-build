linkErrorToSignature()
{
	grep "undefined reference to" | sed -e's|.*undefined reference to `|//cpp-function void |' -e"s|\'| { VOID_BOOM() }|"
}

removeNonLinkErrors()
{
	grep "undefined reference to"
}

makeCppFuncitonFakes()
{
	sed -e's|.*undefined reference to `|//cpp-function void |' -e"s|\'| { VOID_BOOM() }|"
}

listUndefinedCppGlobals()
{
	grep "::" | grep -v "::.*(" | sed -e's|.*undefined reference to `|//cpp-global |' -e"s|\'.*||"	
}

makeCFakes()
{
	sed -e's|.*undefined reference to `|//c-function-or-global EXPLODING_FAKE_FOR(|' -e"s|\'|)|"	
}