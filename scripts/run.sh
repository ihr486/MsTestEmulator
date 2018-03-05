#!/bin/bash

set -e

function show_usage()
{
    echo "Usage: $0 [-c target class] [-m target method] [-o stdout] [-e stderr] [-n] [-h] target"
}

function show_help()
{
	show_usage
	echo << EOS
Emulates the test driver of the Microsoft C++ Unit Test Framework.
Dependencies:
        bash                This script depends on some shell features specific to bash.
        objdump             objdump is used to inspect the DSO.
Options:
        -c <classname>      Only perform test methods included in the test class <classname>.
        -m <methodname>     Only perform test methods with the given name.
        -o <file>           Redirect standard output from the tests into a file.
        -e <file>           Redirect standard error output from the tests into a file.
        -n                  Just take a look at what will happen. (Dry-run)
        -h                  Display this help message and exit.
EOS
	exit 0
}

TARGET_CLASS=
TARGET_METHOD=
STDOUT_FILE=
STDIN_FILE=
DRYRUN_FLAG=false

while getopts c:m:o:e:nh OPT
do
    case ${OPT} in
        c) TARGET_CLASS=$OPTARG
            ;;
        m) TARGET_METHOD=$OPTARG
            ;;
		o) STDOUT_FILE=$OPTARG
			;;
		e) STDIN_FILE=$OPTARG
			;;
		n) DRYRUN_FLAG="true"
			;;
        h) show_help
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -lt 1 ]
then
	show_usage
	exit 1
fi

TARGET_OBJECT=$1

TEST_METHODS=(`objdump -j .testmethod -T -C ${TARGET_OBJECT} | awk 'NF==7{print $7}'`)
TEST_METHODS_MANGLED=(`objdump -j .testmethod -T ${TARGET_OBJECT} | awk 'NF==7{print $7}'`)
TEST_INIT_METHODS=(`objdump -j .testmethodinit -T -C ${TARGET_OBJECT} | awk 'NF==7{print $7}'`)
TEST_INIT_METHODS_MANGLED=(`objdump -j .testmethodinit -T ${TARGET_OBJECT} | awk 'NF==7{print $7}'`)
ALL_METHODS=(`objdump -T -C ${TARGET_OBJECT} | awk 'NF>=7{print $7}NF<7{print "dummy"}'`)
ALL_METHODS_MANGLED=(`objdump -T ${TARGET_OBJECT} | awk 'NF>=7{print $7}NF<7{print "dummy"}'`)

function find_ctor()
{
	for INDEX in "${!ALL_METHODS[@]}"
	do
		if [[ "${ALL_METHODS[${INDEX}]}" =~ TestClassBase(.+)::make\(\) ]]
		then
			if [[ "${BASH_REMATCH[1]}" == "<$1>" ]]
			then
				echo '-c' "${ALL_METHODS_MANGLED[${INDEX}]}"
				return 0
			fi
		fi
	done
	echo "Constructor not found for test class $1. Aborting." >&2
	exit 1
}

function find_runner()
{
	for INDEX in "${!ALL_METHODS[@]}"
	do
		if [[ "${ALL_METHODS[${INDEX}]}" =~ TestClassBase(.+)::run\( ]]
		then
			if [[ "${BASH_REMATCH[1]}" == "<$1>" ]]
			then
				echo '-r' "${ALL_METHODS_MANGLED[${INDEX}]}"
				return 0
			fi
		fi
	done
	echo "Runner not found for test class $1. Aborting." >&2
	exit 1
}

function run_method()
{
	if [[ "${DRYRUN_FLAG}" == "true" ]]
	then
		echo "Would run test method ${TEST_METHODS[$1]}"
	else
		echo "Found test method ${TEST_METHODS[$1]} ..."
	fi

	[[ "${TEST_METHODS[$1]}" =~ ^(.+)::([[:alnum:]_]+)\(\)$ ]] && FULL_CLASS_NAME=${BASH_REMATCH[1]} && METHOD_NAME=${BASH_REMATCH[2]}

	RUNNER_ARGS=""
	for INDEX in "${!TEST_INIT_METHODS[@]}"
	do
		if [[ "${TEST_INIT_METHODS[${INDEX}]}" =~ ^(.+)::([[:alnum:]_]+)\(\)$ ]]
		then
			if [[ "${BASH_REMATCH[1]}" == "${FULL_CLASS_NAME}" ]]
			then
				if [[ "${DRYRUN_FLAG}" == "true" ]]
				then
					echo "Would run test initializer ${TEST_INIT_METHODS[${INDEX}]}"
				else
					echo "Found test initializer ${TEST_INIT_METHODS[${INDEX}]}"
				fi
				RUNNER_ARGS="${RUNNER_ARGS} -i ${TEST_INIT_METHODS_MANGLED[${INDEX}]}"
			fi
		fi
	done

	RUNNER_ARGS="${RUNNER_ARGS} `find_ctor ${FULL_CLASS_NAME}` `find_runner ${FULL_CLASS_NAME}` ${TEST_METHODS_MANGLED[$1]}"
	
	if [[ "${DRYRUN_FLAG}" == "true" ]]
	then
		echo "Would run command:"
		echo " runner ${RUNNER_ARGS}"
	else
		echo ${RUNNER_ARGS}
	fi
}

if [ "${TARGET_CLASS}" ]
then
	echo "Searching for methods in test class" ${TARGET_CLASS} "in" `basename ${TARGET_OBJECT}` "..."
	for INDEX in "${!TEST_METHODS[@]}"
	do
		if [[ ${TEST_METHODS[${INDEX}]} =~ ([[:alnum:]_]+)::([[:alnum:]_]+)\(\)$ ]]
		then
			if [ ${BASH_REMATCH[1]} == ${TARGET_CLASS} ]
			then
				run_method ${INDEX}
			fi
		fi
	done
	if [ "${DRYRUN_FLAG}" != "true" ]
	then
		echo "All tests finished."
	fi
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
				run_method ${INDEX}
			fi
		fi
	done
	if [ "${DRYRUN_FLAG}" != "true" ]
	then
		echo "All tests finished."
	fi
	exit 0
fi

echo "Searching for test methods in" `basename ${TARGET_OBJECT}` "..."
for INDEX in "${!TEST_METHODS[@]}"
do
	run_method ${INDEX}
done
if [ "${DRYRUN_FLAG}" != "true" ]
then
	echo "All tests finished."
fi
exit 0
