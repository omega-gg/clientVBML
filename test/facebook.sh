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

echo "--- facebook ---"
echo ""

test "TRACK" "https://www.facebook.com/watch/?v=1839090492859799"

test "FEED" "https://www.facebook.com/starcraftremasterizado/videos"

test "RELATED" "vbml:run?backend=facebook&method=related&label=tracks&q=1839090492859799"
