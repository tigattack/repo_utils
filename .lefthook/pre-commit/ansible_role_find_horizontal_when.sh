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

. "$(dirname "$0")/utils.sh"

checker() {
  for folder in ${1} ; do
    if [ -d "$folder" ] ; then
      for file in "$folder"/*.yml ; do
        if [ -f "$file" ] ; then
          grep -n ' when: .* and \| when: .* or ' "$file" | while IFS=: read -r linenumber _; do
            if [ -n "$linenumber" ] && [ "$linenumber" -gt 0 ] 2>/dev/null ; then
              echo "${file}:${linenumber} improve readability, spread conditions vertically as a list."
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

# shellcheck disable=SC2043
for binary in grep ; do
  bincheck "$binary"
done

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

for type in tasks handlers ; do
  checker "${sub_folder}/${type}"
done
