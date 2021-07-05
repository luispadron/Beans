#!/bin/bash

swiftlint lint --autocorrect --config .swiftlint.yml Sources Tests
swiftformat --config .swiftformat Sources Tests
