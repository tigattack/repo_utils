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

# A script to find not quoted values in Ansible roles.

. "$(dirname "$0")/utils.sh"

checker() {
  for directory in defaults handlers tasks meta molecule vars ; do
    sub_folder="${1}"
    for folder in $sub_folder/$directory ; do
      if [ -d "$folder" ] ; then
        var_name_pattern='^.*:[a-zA-z0-9\-\_]*:'
        version_pattern='[a-zA-z0-9\-\_]*: [0-9].*\.'
        colon_pattern='[a-zA-z0-9\-\_]*: [a-zA-z0-9\-\_].*:.*'
        pattern="(${version_pattern}|${colon_pattern})"
        matches=$(find "$folder" -name '*.yml' -exec grep -HnE "^${pattern}" {} \; | grep -oE "$var_name_pattern" | sed -e 's/.$//' -e 's/\(:[0-9]*\):/\1: /')
        match_count=$(printf "%s" "$matches" | wc -l)
        if [ -n "$match_count" ] ; then
          if [ "$match_count" -gt 0 ] ; then
            echo "Found $((match_count * 1)) risky and unquoted values in ${folder}:"
            echo "$matches" | sed 's/ \./\n./g'
          fi
        fi
      fi
    done
  done
}

while getopts 'f:' OPTION; do
  case "$OPTION" in
    f)
      sub_folder="$OPTARG"
      ;;
    *)
      echo "Unknown argument: $0 [-f path]" >&2
      exit 1
    ;;
  esac
done
shift "$((OPTIND -1))"

for binary in grep find wc printf; do
  bincheck "$binary"
done

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

# Save the errors in a variable "errors".
errors=$(checker "$sub_folder")

# If the "errors" variable has content, something is wrong.
if [ -n "$errors" ] ; then
  echo "$errors"
  exit 1
fi
