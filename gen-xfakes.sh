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
    * They will explode upon write :-)
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

linkErrorClang()
{
	grep ", referenced from:"
}

isolateUndefinedSymbolsClang()
{
	linkErrorClang | sed -e's/^ *"//' -e's/".*//' -e's/^_//'
}

linkErrorGcc()
{
	grep ": undefined reference to "
}

isolateUndefinedSymbolsGcc()
{
	linkErrorGcc | sed -e's/.*`//' -e"s/'$//"
}

linkErrorVS_C()
{
	grep "LNK2019.*symbol _"
}

linkErrorVS_Cpp()
{
	grep "LNK2019\|LNK2001" | grep ".*symbol \""
}

isolateUndefinedSymbolsVS_C()
{
	linkErrorVS_C | sed -e's/^.*symbol _/__C__/'   -e's/ referenced.*//' -e's/__C__//'
}

isolateUndefinedSymbolsVS_Cpp()
{
	linkErrorVS_Cpp | sed -e's/^.*symbol "/__CPP__/'  -e's/" .*//' -e's/__CPP__//'
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
	cant_exist $4
	preamble$3Fakes $4 $1
	cat $2 | make$3Fakes  >> $4
}

makeCFakes()
{
	grep -v "::" | grep -v "(.*)" | grep -v "typeinfo" | sed -e's/^/EXPLODING_FAKE_FOR(/' -e's/$/)/'
}

makeCppFakes()
{
	grep "(.*)" | sed -e's|^|// void |' -e's/$/ { BOOM_VOID_CPP }/'
}

makeCppGlobalFakes()
{
	grep -v "(.*)" | grep "::" | sed -e's|^|// cpp-global |' -e's/$/;&/'
}

gen_xfakes()
{
	if [ $# -ne 2 ]; then
		usage
	fi

	input_file=$1
	must_exist $input_file
	undefines=$(mktemp)
	sorted_undefines=$(mktemp)

	isolateUndefinedSymbolsGcc <$input_file >$undefines
	isolateUndefinedSymbolsClang <$input_file >>$undefines
	isolateUndefinedSymbolsVS_C <$input_file >>$undefines
	isolateUndefinedSymbolsVS_Cpp <$input_file >>$undefines
	LC_ALL=C sort $undefines | uniq >$sorted_undefines


	fakes_c=$2-c.c	
	fakes_cpp=$2-cpp.cpp	
	fakes_cpp_globals=$2-cpp-globals.cpp
	
	makeFakes $input_file $sorted_undefines C         $fakes_c
	makeFakes $input_file $sorted_undefines Cpp       $fakes_cpp
	makeFakes $input_file $sorted_undefines CppGlobal $fakes_cpp_globals
	rm $undefines
	rm $sorted_undefines

}

if [[ "$(basename -- "$0")" == "gen-xfakes.sh" ]]; then
	gen_xfakes $@
fi
