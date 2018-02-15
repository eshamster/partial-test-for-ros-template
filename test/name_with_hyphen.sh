#!/bin/bash

set -eu

test_name=test-name-with-hyphen

function ros_t()
{
    ros template $@
}

ros_t deinit ${test_name} > /dev/null 2>&1 && :
ros_t init ${test_name}
ros_t checkout ${test_name}
ros_t checkout 2>&1 | grep -E "(${test_name}|default)" && :
ros_t deinit ${test_name}
