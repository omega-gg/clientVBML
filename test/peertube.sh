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

echo "--- peertube ---"
echo ""

test "TRACK" "https://peertube.dsmouse.net/w/719666f2-0fb6-489c-8339-038f902aa55c"

test "TRACK SHORT" "https://peertube.fr/w/2tJSZJJWzXy83ER5A98nBF"
