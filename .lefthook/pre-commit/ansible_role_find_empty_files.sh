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
    if [ -f "${folder}/main.yml" ] ; then
      count=$(wc -l < "${folder}/main.yml")
      min_num=$2
      if [ "$(( count * 1 ))" -le "$(( min_num * 1 ))" ] ; then
        echo "The file ${folder}/main.yml is empty."
        return 1
      fi
    fi
  done
}

while getopts 'f:l:' OPTION; do
  case "$OPTION" in
    f)
      sub_folder="$OPTARG"
      ;;
    l)
      nbr_lines="$OPTARG"
      ;;
    *)
      echo "Unknow argument: $0 [-f path] [-l lines]" >&2
      exit 1
    ;;
  esac
done
shift "$((OPTIND -1))"

# shellcheck disable=SC2043
for binary in wc ; do
  bincheck "$binary"
done

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

if [ -z "$nbr_lines" ]; then
  nbr_lines=2
fi

for type in defaults handlers vars tasks ; do
  checker "${sub_folder}/${type}" "$nbr_lines"
done
