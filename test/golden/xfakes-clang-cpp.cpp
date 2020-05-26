/*
    Fakes generated from: ./example-output/clang-link-errors.txt

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

// void LightSwitch::LightSwitch() { BOOM_VOID_CPP }
// void LightSwitch::Off(int) { BOOM_VOID_CPP }
// void LightSwitch::On(int) { BOOM_VOID_CPP }
// void LightSwitch::~LightSwitch() { BOOM_VOID_CPP }
// void RandomMinuteGenerator::Get() { BOOM_VOID_CPP }
// void RandomMinuteGenerator::RandomMinuteGenerator(int, int) { BOOM_VOID_CPP }
// void RandomMinuteGenerator::~RandomMinuteGenerator() { BOOM_VOID_CPP }
// void Time::Time(Time const&) { BOOM_VOID_CPP }
// void Time::getDay() const { BOOM_VOID_CPP }
// void Time::getMinute() const { BOOM_VOID_CPP }
// void Time::~Time() { BOOM_VOID_CPP }
// void TimeService::TimeService() { BOOM_VOID_CPP }
// void TimeService::getTime() { BOOM_VOID_CPP }
// void TimeService::wakePeriodically(std::__1::unique_ptr<WakeUpAction, std::__1::default_delete<WakeUpAction> >) { BOOM_VOID_CPP }
// void TimeService::~TimeService() { BOOM_VOID_CPP }
// void WakeUpAction::WakeUpAction(int) { BOOM_VOID_CPP }
// void WakeUpAction::~WakeUpAction() { BOOM_VOID_CPP }
