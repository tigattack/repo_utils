#!/bin/sh

# Copyright 2024 Robert de Bock (robert@meinit.nl)
#
# Original source: https://github.com/robertdebock/pre-commit (v1.5.3)
# This file has been modified from the original source.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A script to find unused variables in Ansible roles.

. "$(dirname "$0")/utils.sh"

checker() {
  type="${1}"
  extra_path="${2}"
  vars=""

  for folder in ${extra_path}/${type} ; do
    if [ -d "${folder}" ] && [ -f "${folder}/main.yml" ] ; then
      grep -v '^#' "${folder}/main.yml" | grep -v '^$' | grep -v -- '---' | grep -v '^ ' | grep -v '^_' | cut -d: -f1 | while read -r variable ; do
        matches="$(rg -il "${variable}" -- "${extra_path}" | grep -vEc '(tasks/assert.yml|README.md)')"
        internalmatches="$(grep -ic "${variable}" "${folder}/main.yml")"
        if [ "${matches}" -le 1 ] && [  "${internalmatches}" -le 1 ] ; then
          echo "${folder}/main.yml defines ${variable} which is not used."
        fi
        vars="${vars} ${variable}"
      done
    fi
  done
}

while getopts 'f:' OPTION; do
  case "$OPTION" in
    f)
      sub_folder="$OPTARG"
      ;;
    *)
      echo "Unknow argument: $0 [-f path]" >&2
      exit 1
    ;;
  esac
done

for binary in rg grep cut ; do
  bincheck "$binary"
done

shift "$((OPTIND -1))"

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

# Save the errors in a variable "errors".
errors=$(for type in defaults vars ; do checker "${type}" "${sub_folder}" ; done)

# If the "errors" variable has content, something is wrong.
if [ -n "${errors}" ] ; then
  echo "${errors}"
  exit 1
fi
