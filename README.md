# Crash to Pass Toolkit

## `legacy-build`, `legacy-suggest` and `gen-xfakes`

This repo has scripts to help C and C++ programmers drag unwilling legacy C and C++ into a test harness.

The recipe for getting legacy C/C++ is described in
[TDD How-to: Get your Legacy C Into a Test Harness](https://wingman-sw.com/articles/tdd-legacy-c) 

## Usage

In your local build directory add a file like this

```
LEGACY_BUILD=~/repos/github/legacy-build/legacy-build.sh

INCLUDE_ROOT=.
MY_BUILD_DIR=.
MY_BUILD_COMMAND=make

bash $LEGACY_BUILD $MY_BUILD_DIR $MY_BUILD_COMMAND
```

### legacy-build.sh -- main entry point

Runs MY_BUILD_COMMAND in the working directory, captures the 
output, passes it to `legacy-suggest` which may make a suggestion about how
to solve the current problem.  If you use CppUTest, some suggestions can be cut and pasted into your makefile.

Finally, when you get to linker errors, `legacy-build` will
generate eploding fakes to get you past linker problems and on to running your code.

Set your build so that it fails on the first error.
For gcc and clang `-Wfatal-errors`.

So far, this has been tested on
* ubuntu gcc version 9.3.0.
* mac osx gcc version 7.4.0

### legacy-suggest -- helper

Takes a gcc compiler error output, and filters the error, and makes a suggestion.

The suggestions handle a couple common legacy code test-build problems, like missing includes and linker errors.

### gen-xfakes -- helper

Generate exploding fakes from c/c++ linker error output (used for unit testing).  

`gen-xfakes.sh` produces three files with the supplied basename `xfakes`

|   |   |
|---    |---    |
| `tmp-xfakes-c.c`              | C linkage fakes, ready to add to your build |
| `tmp-xfakes-cpp.cpp`          | C++ linkage fakes, edits needed |
| `tmp-xfakes-cpp-globals.cpp`  | C++ undefined globals, edits needed |

For C linker errors, the resutling file can be added to the build and those link errors go away.  They later turn into runtime errors as exit the test runner whenever your code executes and exploding fake.  Usually when you hit an exploding fake, you want the fake to do nothing, or possible you will need a smarter fake.

For C++ errors, you need to do some editing.  `tmp-xfakes-cpp.cpp` will contain a fair guess at what the missing function is that you need.  You'll need to add include files and adjust function signatures.

## Supported formats

 * g++ linker output
 * clang
 * Visual Studio -- best guess
 * Feel free to give me a contribution
 * All these compilers are moving target, so you may have to fiddle with it.

# Examples

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
