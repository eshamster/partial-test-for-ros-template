#!/bin/bash

set -eu

dumped=/root/.roswell/env/roswell/impls/x86-64/linux/sbcl-bin/1.4.0/dump/roswell.core
if [ -f "${dumped}" ]; then
   rm "${dumped}"
fi
