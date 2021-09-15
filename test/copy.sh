#!/bin/sh
set -e

# NOTE: We copy each test in the bin folder.
cp *.sh ../bin

# NOTE: We don't want this script in the bin folder.
rm ../bin/copy.sh
