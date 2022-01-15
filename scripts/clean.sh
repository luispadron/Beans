#!/bin/bash

set -e

echo "🧼 Cleaning the project"
git clean -xdn
rm -rf .build
rm -rf Tools/.build
echo "🧼 Project cleaned!"