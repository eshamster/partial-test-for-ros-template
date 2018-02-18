#!/bin/bash

set -eu

root_dir="$(readlink -f $(dirname ${0}))/.."
. "${root_dir}/setenv"

test_name=test-export

my_work_dir="${WORK_DIR}/export_work"
export_dir="${WORK_DIR}/export"

function clean_export_dir()
{
    for dir in "${my_work_dir}" "${export_dir}"; do
        rm -rf "${dir}"
        mkdir -p "${dir}"
    done
}

clean_export_dir

function ros_t()
{
    ros template $@
}

echo "--- create template ---"
(
    cd "${my_work_dir}"

    ros_t deinit ${test_name} > /dev/null 2>&1 && :
    ros_t init ${test_name}
    ros_t checkout ${test_name}

    echo "abc {{ name }} def" > file1
    echo "fed {{ eman }} cba" > file2

    ros_t add file1 file2
    ros_t type djula file1

    ros_t list
)

echo "--- export ---"
(
    cd "${export_dir}"
    ros_t export
    echo "- check file list -"
    find . | sort
    echo "- check file content"
    echo "> file1"
    cat file1
    echo "> file2"
    cat file2
)

echo "--- modify templates ---"
echo "- with direcctory -"
(
    cd "${my_work_dir}"

    echo "additional line" >> file1
    mkdir dir
    echo "aaa {{ bbb }} ccc" > dir/file3

    ros_t add file1 dir/file3
    ros_t rm file2

    ros_t list
)

echo "--- re-export ---"
(
    cd "${export_dir}"

    # Note: The remove of file2 is ignored when exporting
    ros_t export

    echo "- check file list -"
    find . | sort
    echo "- check file content"
    echo "> file1"
    cat file1
    echo "> dir/file3"
    cat dir/file3
)

echo "--- export to another pass ---"
(
    cd "${export_dir}"

    ros_t export output_dir
    find output_dir | sort
)

echo "--- try to export default ---"
ros_t checkout default
ros_t export 2>&1 && :

echo "--- export not default template ---"
(
    clean_export_dir
    cd "${export_dir}"

    ls # should display nothing

    ros_t checkout default

    ros_t export ${test_name}
    find . -name "*asd"
    ros_t export ${test_name} output_dir
    find . -name "*asd"
)

ros_t deinit ${test_name}
