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

# A script to find empty directories in Ansible roles.

. "$(dirname "$0")/utils.sh"

checker() {
  if [ -d "${1}" ] ; then
    count=$(find "${1}" | wc -l)
    if [ "$count" -lt 2 ] ; then
      echo "The directory ${1} is empty."
      return 1
    fi
  fi
}

while getopts 'f:d:' OPTION; do
  case "$OPTION" in
    f)
      sub_folder="$OPTARG"
      ;;
    d)
      maxdepth="$OPTARG"
      ;;
    *)
      echo "Unknown argument: $0 [-f path]" >&2
      exit 1
    ;;
  esac
done
shift "$((OPTIND -1))"

for binary in find wc ; do
  bincheck "$binary"
done

if [ -z "$sub_folder" ]; then
  sub_folder="."
fi

if [ -z "$maxdepth" ]; then
  maxdepth=1
fi

find "$sub_folder/" -maxdepth "$maxdepth" -type d -not -name '.*' | while read -r dir ; do
  checker "$dir"
done
