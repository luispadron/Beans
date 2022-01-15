#!/bin/bash

set -e

./Scripts/tools.sh setup

# Run swift-format
if [ ${1:-""} == "lint" ]; then
  echo "🚓 Linting the project"
  ./Tools/.build/release/swift-format lint --parallel --recursive Sources Tests Package.swift Tools/Package.swift
  echo "🚓 Linting finished without violations"
else
  echo "🧹 Formatting the project"
  ./Tools/.build/release/swift-format --parallel --recursive -i Sources Tests Package.swift Tools/Package.swift
  echo "🧹 Project formatted!"
fi
