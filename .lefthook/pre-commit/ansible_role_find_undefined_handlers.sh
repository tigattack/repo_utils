#!/bin/sh

# Copyright 2024 Robert de Bock (robert@meinit.nl)
#
# Original source: https://github.com/robertdebock/pre-commit (v1.5.3)
# This file is unmodified from the original source.
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

# A script to find handlers that are called but not defined in Ansible roles.

for binary in grep cut sort uniq awk sed ; do
  which "${binary}" > /dev/null 2>&1 || (echo "Missing ${binary}, please install it." ; exit 1)
done

checker() {
  for folder in ${1} ; do
    # See if there any handlers.
    if [ -d "${folder}"/handlers ] && [ -f "${folder}"/handlers/main.yml ] ; then
      # See if there are any handlers called by notify.
      for file in "${folder}"/tasks/*.yml ; do
        if grep -q 'notify:' "${file}" ; then
          # Filter out the called handlers.
          notification=$(awk '$1 == "-"{ if (key == "notify:") print $0; next } {key=$1}' "${file}"| sed 's/ *- //' | sort | uniq)
          echo "${notification}" | while read -r notify ; do
            if ! grep -q -- "- name: ${notify}" "${1}"/handlers/main.yml ; then
              echo "The notification to \"${notify}\" in ${file} is not mention in any handlers/main.yml."
            fi
          done
        fi
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
shift "$((OPTIND -1))"

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

# Save the errors in a variable "errors".
errors=$(checker "${sub_folder}")

# If the "errors" variable has content, something is wrong.
if [ -n "${errors}" ] ; then
  echo "${errors}"
  exit 1
fi

