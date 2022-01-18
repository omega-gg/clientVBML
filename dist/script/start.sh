#!/bin/sh
set -e

echo "Starting clientVBML..."

PWD=$(dirname "$(readlink -f "$0")")

export LD_LIBRARY_PATH="$PWD"

export QT_PLUGIN_PATH="$PWD"

"$PWD/clientVBML" "$1"
