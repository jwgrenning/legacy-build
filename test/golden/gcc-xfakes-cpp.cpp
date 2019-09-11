/*
    File: xfakes-cpp.cpp From: example-gcc-link-errors.txt

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

// void AcmeCrypto_RemoveKeyFile(char const*) { BOOM_VOID_CPP }
// void AcmeDatabase_GetCloudserver1Linked(bool*) { BOOM_VOID_CPP }
// void AcmeDatabase_SetCloudserver1Linked(bool) { BOOM_VOID_CPP }
// void AcmeRegistry::AcmeRegistry() { BOOM_VOID_CPP }
// void AcmeRegistry::Write(char const*, char const*) { BOOM_VOID_CPP }
// void AcmeRegistry::~AcmeRegistry() { BOOM_VOID_CPP }
// void AcmeUpdateTZEnv(char const*, char const*) { BOOM_VOID_CPP }
// void AcmeWpa::clockGetSeconds() { BOOM_VOID_CPP }
// void AcmeWpa::restartDhcp(double, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >*) { BOOM_VOID_CPP }
