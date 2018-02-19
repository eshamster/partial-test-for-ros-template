#!/bin/bash

set -eu

root_dir="$(readlink -f $(dirname ${0}))/.."
. "${root_dir}/setenv"

test_name=test-import

import_dir="${WORK_DIR}/import"

function clean_import_dir()
{
    cd "${WORK_DIR}"

    rm -rf "${import_dir}"
    cp -R "${RESOURCE_DIR}"/import "${import_dir}"
}

clean_import_dir

function ros_t()
{
    ros template $@
}


echo "--- import ---"
(
    ros_t deinit ${test_name} && :
    ros_t checkout | grep ${test_name} && :

    cd "${import_dir}"
    ros_t import
    ros_t list ${test_name}
)

echo "--- import other dir ---"
(
    ros_t deinit ${test_name} && :
    (ros_t checkout | grep ${test_name}) && :

    cd "${WORK_DIR}"
    ros_t import "${import_dir}"
    ros_t list ${test_name}
)

echo "--- case where a file is not exist ---"
(
    clean_import_dir

    cd "${import_dir}"
    rm file1
    ros_t import "${import_dir}" && :
    echo "errno: $?"

    clean_import_dir
)

echo "--- case where there is no asd ---"
(
    clean_import_dir

    cd "${import_dir}"
    rm *asd
    ros_t import "${import_dir}" 2>&1 | grep '"roswell.init.*.asd" is not exist' && :

    clean_import_dir
)

ros_t deinit ${test_name}
