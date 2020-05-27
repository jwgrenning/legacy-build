#!/bin/bash

test_files=$(ls test-*.sh)
test_out=all-test.out
rm -f $test_out

for test_file in $test_files; do
    bash ./$test_file | sed -e"s/OK/& -- ${test_file}/" -e"s/FAILED/& -- ${test_file}/" >>$test_out
done

if [ ! -z "$(grep "FAILED" $test_out)" ]; then
    cat $test_out
fi

grep -e OK -e Ran  $test_out

