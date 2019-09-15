/*
    File: vs-xfakes-c.c From: example-vs-link-errors.txt

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


EXPLODING_FAKE_FOR(Add_double)
EXPLODING_FAKE_FOR(Get_Digit_UINT32)
EXPLODING_FAKE_FOR(Set_Digit_UINT16)
EXPLODING_FAKE_FOR(_imp_icudt62_dat)
EXPLODING_FAKE_FOR(errorHalt)
