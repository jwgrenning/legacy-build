# gen-xfakes

Generate exploding fakes from c/c++ linker error output (used for unit testing)

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

 ## To be supported formats

 * clang
 * Visual Studio


 ## Examples

 See `test/example-gcc-link-errors.txt` for example input.  The output files
 are found in `test/golden`.

 A full explanation of how to use `gen-xfakes` is on my blog [here](http://blog.wingman-sw.com/wrestle-legacy-c-cpp-into-tests-linker-errors).
 
