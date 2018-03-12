#!/bin/bash

set -eux

root_dir="$(readlink -f $(dirname ${0}))/.."
. "${root_dir}/setenv"

test_name=test-normal
init_dir="${WORK_DIR}/init_normal"

rm -rf "${init_dir}"
mkdir -p "${init_dir}"

function ros_t()
{
    ros template $@
}

ros_t deinit ${test_name} > /dev/null 2>&1 && :

echo "--- create template ---"
ros_t init ${test_name}
ros_t checkout ${test_name}

(
    cd "${WORK_DIR}"
    echo "sample_{{name}}" > file_normal
    echo "sample_{{name}}_{{self}}" > file_djula
    echo "sample" > file_rename

    ros_t add file_normal

    ros_t add file_djula
    ros_t type djula file_djula

    ros_t add file_rename
    ros_t rewrite file_rename "rename_{{name}}.txt"

    echo "- check content -"
    ros_t list
    ros_t cat file_normal
)

echo "--- init using the template ---"
(
    cd "${init_dir}"
    ls
    ros init ${test_name} sample --self this
    echo "- check content -"
    ls | sort
    ls | sort | xargs head
)

echo "--- remove item ---"
(
    ros_t rm file_djula
    ros_t list
)

echo "--- cleanup ---"
ros_t deinit ${test_name} 2>&1 && :
