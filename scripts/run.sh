#!/bin/bash

function show_usage()
{
    echo "Usage: $0 [-c target class] [-m target method] target"
    exit 1
}

TARGET_CLASS=
TARGET_METHOD=

while getopts c:m:h OPT
do
    case ${OPT} in
        c) TARGET_CLASS=$OPTARG
            ;;
        m) TARGET_METHOD=$OPTARG
            ;;
        h) show_usage
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -lt 1 ]
then
	show_usage
fi

TARGET_OBJECT=$1

TEST_METHODS=(`objdump -j .testmethod -T -C $TARGET_OBJECT | awk 'NF==7{print $7}'`)
TEST_METHODS_MANGLED=(`objdump -j .testmethod -T -C $TARGET_OBJECT | awk 'NF==7{print $7}'`)

if [ "${TARGET_CLASS}" ]
then
	echo "Searching for methods in test class" ${TARGET_CLASS} "in" `basename ${TARGET_OBJECT}` "..."
	for INDEX in "${!TEST_METHODS[@]}"
	do
		if [[ ${TEST_METHODS[${INDEX}]} =~ ([[:alnum:]_]+)::([[:alnum:]_]+)\(\)$ ]]
		then
			if [ ${BASH_REMATCH[1]} == ${TARGET_CLASS} ]
			then
				echo "Found test method" ${TEST_METHODS[${INDEX}]}
			fi
		fi
	done
	echo "All tests finished."
	exit 0
fi

if [ "${TARGET_METHOD}" ]
then
	echo "Searching for test methods" ${TARGET_METHOD} "in" `basename ${TARGET_OBJECT}` "..."
	for INDEX in "${!TEST_METHODS[@]}"
	do
		if [[ ${TEST_METHODS[${INDEX}]} =~ ([[:alnum:]_]+)::([[:alnum:]_]+)\(\)$ ]]
		then
			if [ ${BASH_REMATCH[2]} == ${TARGET_METHOD} ]
			then
				echo "Found test method" ${TEST_METHODS[${INDEX}]}
			fi
		fi
	done
	echo "All tests finished."
	exit 0
fi

echo "Searching for test methods in" ${TARGET_OBJECT} "..."
for INDEX in "${!TEST_METHODS[@]}"
do
	if [[ ${TEST_METHODS[${INDEX}]} =~ ([[:alnum:]_]+)::([[:alnum:]_]+)\(\)$ ]]
	then
		echo "Found test method" ${TEST_METHODS[${INDEX}]}
	fi
done
