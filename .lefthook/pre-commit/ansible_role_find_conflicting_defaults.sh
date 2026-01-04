#!/bin/bash

. "$(dirname "$0")/utils.sh"

checker() {
  yq '.argument_specs.main.options | keys | .[]' meta/argument_specs.yml | while read -r var; do
    # Skip required variables
    required=$(yq ".argument_specs.main.options.${var}.required // false" meta/argument_specs.yml)
    if [ "$required" = "true" ]; then
      continue
    fi

    # Get default from argspec
    argspec_default=$(yq ".argument_specs.main.options.${var}.default" meta/argument_specs.yml)

    # Get value from defaults
    defaults_value=$(yq ".${var}" defaults/main.yml)

    # Skip Jinja templates
    if echo "$defaults_value" | grep -q '{{'; then
      continue
    fi

    # Compare
    if [ "$argspec_default" != "$defaults_value" ]; then
      echo "${var}: argspec='${argspec_default}' != defaults='${defaults_value}'"
    fi
  done
}

for binary in yq grep ; do
  bincheck "$binary"
done

if [ ! -f "meta/argument_specs.yml" ]; then
  echo "Argument specs not found, skipping check."
  exit 0
fi

errors=$(checker)

if [ -n "$errors" ] ; then
  echo "$errors"
  exit 1
fi
