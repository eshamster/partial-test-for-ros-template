#!/bin/bash

set -u

root_dir="$(readlink -f $(dirname ${0}))"
expected_dir="${root_dir}/expected"
result_dir="${root_dir}/result"

args=($@)

if [ ! -d "${root_dir}/lib/shunit2" ]; then
    (
        cd "${root_dir}/lib"
        shunit_ver=2.1.6
        wget -O - https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-${shunit_ver}.tgz | tar zxf -
        mv shunit2-${shunit_ver} shunit2
    )
fi

function resultFilePath() { echo "${result_dir}/$1.txt"; }
function errorFilePath() { echo "${result_dir}/$1.error.txt"; }
function diffFilePath() { echo "${result_dir}/$1.diff.txt"; }

function checkResult()
{
    local name=$1
    local expected="${expected_dir}/${name}.txt"
    local result="$(resultFilePath ${name})"

    if [ ! -f "${expected}" ]; then
        fail "There is no expected file: \"${expected}\""
    fi
    if [ ! -f "${result}" ]; then
        fail "There is no result file: \"${result}\""
    fi

    assertTrue "Test ${name}" "diff ${expected} ${result} > $(diffFilePath ${name})"
}

function oneTimeSetUp()
{
    "${root_dir}/lib/init_roswell.sh"
    echo "Note: Removed dump" 1>&2

    if [ -d "${result_dir}" ]; then
        rm -r "${result_dir}"
    fi
    mkdir "${result_dir}"
}

function runOneCase()
{
    local name=$1
    local test="${root_dir}/test/${name}.sh"

    if [ ! -f "${test}" ]; then
        fail "There is not the test: \"${test}\""
    fi

    ${test} > "$(resultFilePath ${name})" 2> "$(errorFilePath ${name})"
    checkResult ${name}
}

function testNormal() { runOneCase normal; }
function testDeinit() { runOneCase deinit; }
function testAddTwice() { runOneCase add_twice; }
function testNameWithHyphen() { runOneCase name_with_hyphen; }
function testExport() { runOneCase export; }
function testImport() { runOneCase import; }
function testDefaultType { runOneCase default_type; }

# function suite() { suite_addTest testNormal; }

. "${root_dir}/lib/shunit2/src/shunit2"
