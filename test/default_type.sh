#!/bin/bash

set -eu

root_dir="$(readlink -f $(dirname ${0}))/.."
. "${root_dir}/setenv"

test_name=test-default-type

function ros_t()
{
    ros template $@
}

ros_t deinit ${test_name} > /dev/null 2>&1 && :

ros_t init ${test_name}
ros_t checkout ${test_name}

(
    cd "${WORK_DIR}"

    echo test > file1
    ros_t add file1

    ros_t type

    echo "--- change default type ---"
    ros_t type djula
    echo test > file2
    ros_t add file2

    ros_t list
    ros_t type

    echo "--- add file1 again (doesn't change type) ---"
    ros_t add file1

    ros_t list
    ros_t type
)

ros_t deinit ${test_name}
