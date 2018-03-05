#!/bin/bash

function show_usage()
{
    echo "Usage: ListUnitTests.sh [Target object]" >2
}

if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

echo `basename $1`
echo "Test methods:"
objdump -j .testmethod -T -C $1 | awk 'match($7, /[[:alnum:]_]+::[[:alnum:]_]+\(\)$/) {print "\t" substr($7, RSTART, RLENGTH)}' 
echo "Test initializers:"
objdump -j .testmethodinit -T -C $1 | awk 'match($7, /[[:alnum:]_]+::[[:alnum:]_]+\(\)$/) {print "\t" substr($7, RSTART, RLENGTH)}'
