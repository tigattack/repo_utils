#!/bin/sh

# Shared utility functions for pre-commit hooks

bincheck() {
  which "$1" > /dev/null 2>&1 || (echo "Missing $1, please install it." ; exit 1)
}
