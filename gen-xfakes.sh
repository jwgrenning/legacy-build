preambleCFakes()
{
	cat > $1 <<- EOM
/*
    File: $(basename -- $1) From: $(basename -- $2)

 	Generated file to help to quickly stub C-linkage unresolved external references

 	* When EXPLODING_FAKE_FOR is executed, a message is printed and the test run is existed
 	* You could customize EXPLODING_FAKE_FOR to only fail the test
    * Add this file to your test build.
    * Do not include the header files for the referenced functions. The C-linker does not care.

 	Note: a EXPLODING_FAKE_FOR() is generated for global variables too.
    * They will explode upong write :-)
    * You might want to resolve these a different way.

*/

#include <stdio.h>
#include <stdlib.h>

#define BOOM_MESSAGE printf("BOOM! time to write a better fake for %s\n", __func__)
#define EXPLODING_FAKE_FOR(f) void f(void); void f(void) { BOOM_MESSAGE; exit(1); }
#define NULL_VOID_FAKE_FOR(f) void f(void); void f(void) {}
#define NULL_VALUE_FAKE_FOR(value_type, f, result) value_type f(void); value_type f(void) { return result; }


EOM
}

preambleCppFakes()
{
	cat > $1 <<- EOM
/*
    File: $(basename -- $1) From: $(basename -- $2)

 	Generated file to help to quickly stub C++ undefined external functions.
 	
    * Add this file to your test build.
    * One at a time
      * Uncomment an exploing fake function definition.
      * Add needed the include file.
      * Modify non-void function return types and propvide a return value.
      * Fix errors.
      * Work carefully. Use the compiler and link error output to test your changes.

    * You could customize the BOOM macros to only fail the test, rather than exit the 
      test runner.

*/

#include <stdio.h>
#include <stdlib.h>

#define BOOM_MESSAGE printf("BOOM! time to write a better fake for %s\n", __func__) 
#define BOOM_VOID_CPP BOOM_MESSAGE; exit(1);
#define BOOM_VALUE_CPP(result) BOOM_MESSAGE; exit(1); return result;

/*
*   Production code header files
*/

// #include "your.h"

EOM
}

preambleCppGlobalFakes()
{
	cat > $1 <<- EOM
/*
    File: $(basename -- $1) From: $(basename -- $2)

 	Generated file to help to quickly stub C++ undefined external globals.
 	
    * One at a time
      * Add the file containing the global definition to your build or
        add the global data definition (and its declaratiob) to this file.
        Adding the global to this file is probably not sustainable, but a
        pragmatic choice until you decide how to better organioze your global
        data.
      * Add include files as neededd.
      * Work carefully. Use the compiler and link error output to test your changes.

*/

EOM
}

removeNonLinkErrors()
{
	grep "undefined reference to"
}

makeCppFakes()
{
	grep "(.*).*(.*)" | sed -e's|.*undefined reference to `|// void |' -e"s|\'| { BOOM_VOID_CPP }|"
}

makeCppGlobalFakes()
{
	grep "::" | grep -v "(.*).*(.*)" | sed -e's|.*undefined reference to `|//cpp-global |' -e"s|\'.*|;|"	
}

makeCFakes()
{
	grep -v "(.*).*(.*)" | grep -v "::" | sed -e's|.*undefined reference to `|EXPLODING_FAKE_FOR(|' -e"s|\'|)|"	
}

usage()
{
	echo "usage $0 linker-error-output.txt out-file-basename"
	exit 1
}

must_exist()
{
	if [ ! -e $1 ]; then
		echo "Input file does not exist: $1"
		exit 1
	fi
}

cant_exist()
{
	if [ -e $1 ]; then
		echo "Output file exists: $1"
		exit 1
	fi
}

makeFakes()
{
	cant_exist $3
	preamble$2Fakes $3 $1
	cat $1 | removeNonLinkErrors | make$2Fakes | sort | uniq  >> $3
}

gen_xfakes()
{
	if [ $# -ne 2 ]; then
		usage
	fi

	input_file=$1
	must_exist $input_file

	fakes_c=$2-c.c	
	fakes_cpp=$2-cpp.cpp	
	fakes_cpp_globals=$2-cpp-globals.cpp
	
	makeFakes $input_file C         $fakes_c 
	makeFakes $input_file Cpp       $fakes_cpp 
	makeFakes $input_file CppGlobal $fakes_cpp_globals  
}

if [[ "$(basename -- "$0")" == "gen-xfakes.sh" ]]; then
	gen_xfakes $@
fi
