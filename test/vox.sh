#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

test()
{
    echo "$1 $2"

    # NOTE: We don't want to output anything by default.
    if ./clientVBML "$2" > /dev/null 2>&1; then
        echo "[OK]"
    else
        echo "FAIL"
    fi

    echo ""
}

#--------------------------------------------------------------------------------------------------
# Requests
#--------------------------------------------------------------------------------------------------

echo "--- vox ---"
echo ""

test "TRACK" "https://vox.omega.gg/w/bj3KJGQcXVMsaDfSLJHjGX"

test "RELATED" "vbml:run?backend=vox&method=related&label=tracks&q=vox.omega.gg/w/bj3KJGQcXVMsaDfSLJHjGX"

# NOTE: We need to encode the url to provide the #t=1 extension.
test "RELATED TIME" "vbml:run?backend=vox&method=related&label=tracks&q=vox.omega.gg%2Fw%2Fbj3KJGQcXVMsaDfSLJHjGX%2523t%3D1"

test "SEARCH TRACKS" "vbml:run?backend=vox&method=search&label=tracks&q=vox"
