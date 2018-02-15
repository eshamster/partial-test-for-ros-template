#!/bin/bash

set -eu

root_dir="$(readlink -f $(dirname ${0}))/.."
. "${root_dir}/setenv"

test_name=test_deinit

file=test

function ros_t()
{
    ros template $@
}

function check_status()
{
    ros_t checkout 2>&1 | grep -E "(current default|${test_name})" || :
    ls -F ~/.roswell/local-projects/templates | grep ${test_name} || :
}

echo "--- before --- "
ros_t checkout default
check_status
echo "--- after init --- "
ros_t init ${test_name}
ros_t checkout ${test_name}
check_status

(
    echo "--- add a file ---"
    cd "${WORK_DIR}"
    echo sample > ${file}

    ros_t add ${file}
    ros_t list
)

echo "--- after deinit --- "
ros_t deinit ${test_name}
check_status
echo "--- deinit again --- "
ros_t deinit ${test_name} 2>&1 && :
echo "errno: $?"

echo "--- try to remove default ---"
ros_t deinit default 2>&1 && :
echo "errno: $?"

echo "--- use deinit without template name ---"
ros_t deinit 2>&1 && :
echo "errno: $?"
