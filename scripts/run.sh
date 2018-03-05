#!/bin/bash

function show_usage()
{
    echo "Usage: $0 [-c Test class] [-m Test method] target"
    exit 1
}

TEST_CLASS=
TEST_METHOD=

while getopts c:m:h OPT
do
    case ${OPT} in
        c) TEST_CLASS=$OPTARG
            ;;
        m) TEST_METHOD=$OPTARG
            ;;
        h) show_usage
            ;;
    esac
done


