/*
    Fakes generated from: ./example-output/vs-link-errors.txt

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

// void __declspec(dllimport) const icu_62::ErrorCode::`vftable' { BOOM_VOID_CPP }
// void __declspec(dllimport) public: enum UErrorCode __cdecl icu_62::ErrorCode::reset(void) { BOOM_VOID_CPP }
// void __declspec(dllimport) public: signed char __cdecl icu_62::ErrorCode::isSuccess(void)const  { BOOM_VOID_CPP }
// void __declspec(dllimport) public: static double __cdecl vtkLine::DistanceToLine(double * const,double * const,double * const) { BOOM_VOID_CPP }
// void __declspec(dllimport) public: static double __cdecl vtkLine::DistanceToLine(double * const,double * const,double * const,double &,double * const) { BOOM_VOID_CPP }
// void __declspec(dllimport) public: virtual signed char __cdecl icu_62::UCharCharacterIterator::hasNext(void) { BOOM_VOID_CPP }
