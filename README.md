# Crash to Pass (`legacy-build` and `gen-xfakes`)

This repo has two scripts to help C and C++ programmers drag unwilling legacy C and C++ into a test harness.

The recipe for getting legacy C/C++ is described in
[TDD How-to: Get your Legacy C Into a Test Harness](https://wingman-sw.com/articles/tdd-legacy-c) 

### legacy-build.sh

Runs the makefile in the working directory, captures the 
output and makes a suggestion about how to solve the 
current problem.  If you use CppUTest, some suggestions can be cut and pasted into your makefile.

Finally, when you get to linker errors, legacy-build will
run gen-xfakes to generate eploding fakes to get you past
linker problems and on to running your code.

Set your build so that it fails on the first error.
For gcc and clang `-Wfatal-errors`.

So far, this has only been tested on gcc version 9.3.0.


### gen-xfakes 

Generate exploding fakes from c/c++ linker error output (used for unit testing).  

For C linker errors, the resutling file can be added to the build and those link errors go away.  They later turn into 
runtime errors as exit the test runner whenever you code
executes and exploding fake.  For C++ errors, you need to do some editing.

## Usage

Capture the linker error output and feed it to the gen-xfakes.sh

```

$ make 2>error-output.txt
$ path/to/gen-xfakes.sh error-output.txt xfakes

```

`gen-xfakes.sh` produces three files with the supplied basename `xfakes`

|	|	|
|---	|---	|
| `xfakes-c.c` 				| C linkage fakes, ready to add to your build |
| `xfakes-cpp.cpp`			| C++ linkage fakes, edits needed |
| `xfakes-cpp-globals.cpp`	| C++ undefined globals, edits needed |

 ## Supported formats

 * g++ linker output
 * clang
 * Visual Studio -- best guess
 * Feel free to give me a contribution

 ## To be supported formats


 ## Examples

 See `test/example-output/gcc-link-errors.txt` for example input.  The output files
 are found in `test/golden`.

 A full explanation of how to use `gen-xfakes` is on my blog [here](http://blog.wingman-sw.com/wrestle-legacy-c-cpp-into-tests-linker-errors).
 
## Run the tests on your machine

Clone everying including the tests

```
$ git clone <repo>
$ git submodule update --init
```

Run the tests
```
cd tests
./all-tests.sh
```
