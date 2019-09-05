/*
    File: myfakes-c.c From: example-gcc-link-errors.txt

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

#define EXPLODING_FAKE_FOR(f) void f { printf("BOOM! time to write a better fake for %s\n", __func__); exit(1); }
#define NULL_VOID_FAKE_FOR(f) void f { }
#define NULL_VALUE_FAKE_FOR(f, value_type, result) value_type f { return result; }


EXPLODING_FAKE_FOR(log_it)
EXPLODING_FAKE_FOR(myJSON_AddStringToObject)
EXPLODING_FAKE_FOR(myJSON_CreateObject)
EXPLODING_FAKE_FOR(myJSON_Delete)
EXPLODING_FAKE_FOR(myJSON_GetObjectItem)
EXPLODING_FAKE_FOR(myJSON_IsString)
EXPLODING_FAKE_FOR(pthread_setname_np)
