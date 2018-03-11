#!/bin/bash

set -eu

test_name=test-duplicated-add
file=sample

function ros_t()
{
    ros template $@
}

ros_t deinit ${test_name} > /dev/null 2>&1 && :
ros_t init ${test_name}
ros_t checkout ${test_name}
ros_t rm ${file}

echo "First" > ${file}
ros_t add ${file}

ros_t list
ros_t cat ${file}
ros_t type djula ${file}

echo "Second" > ${file}
ros_t add ${file}

ros_t list
ros_t cat ${file}
