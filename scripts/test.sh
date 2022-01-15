#!/bin/bash

set -eu

echo "Linting project"
./Scripts/style.sh lint

echo "🧪 Runing project tests"
swift test --parallel --sanitize thread
echo "🧪 Running project tests succeeded"