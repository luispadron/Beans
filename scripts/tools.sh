#!/bin/bash

set -e

case "$1" in
  setup)
    echo "⚙️  Setting up tools"

    pushd Tools
    swift build -c release --product swift-format
    popd

    echo "⚙️  Tools setup!"
    ;;
  update)
    echo "⚙️  Updating tools"

    pushd Tools
    swift update
    swift build -c release --product swift-format
    popd
    
    echo "⚙️  Tools updated!"
    ;;
  *)
    echo "🤷‍♂️  Unknown command"
    ;;
esac